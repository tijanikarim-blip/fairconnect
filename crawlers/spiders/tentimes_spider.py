import scrapy
from datetime import datetime
from urllib.parse import urljoin
from crawlers.items import ExhibitionItem


class TentimesSpider(scrapy.Spider):
    name = "10times"
    allowed_domains = ["10times.com"]
    start_urls = ["https://10times.com/tradeshows"]

    custom_settings = {
        "DOWNLOAD_DELAY": 2.0,
        "CONCURRENT_REQUESTS": 8,
    }

    def parse(self, response):
        for card in response.css(".event-card, .trade-show-card, [data-testid='event-card']"):
            item = ExhibitionItem()
            item["source"] = "10times"
            link = card.css("a::attr(href)").get()
            item["source_url"] = urljoin(response.url, link) if link else response.url
            item["name"] = card.css("h3::text, .event-title::text").get("").strip()
            item["country"] = card.css(".location::text, .event-location::text").get("").strip()
            date_text = card.css(".date::text, .event-date::text").get("")
            item["start_date"], item["end_date"] = self._parse_dates(date_text)
            item["organizer"] = card.css(".organizer::text").get("").strip()
            item["industries"] = [card.css(".category::text, .industry-tag::text").get("").strip()] if card.css(".category::text, .industry-tag::text") else []
            item["venue"] = card.css(".venue::text").get("").strip()
            item["city"] = card.css(".city::text").get("").strip() or item["country"].split(",")[0].strip() if "," in item["country"] else ""

            yield scrapy.Request(
                url=item["source_url"],
                callback=self.parse_detail,
                cb_kwargs={"item": item},
                dont_filter=True,
            )

        next_page = response.css("a.next, .pagination a.next::attr(href)").get()
        if next_page:
            yield response.follow(next_page, self.parse)

    def parse_detail(self, response, item):
        item["description"] = response.css(
            ".description::text, .event-description p::text, [data-section='description'] p::text"
        ).get("").strip()
        item["registration_url"] = response.css(
            "a.register, .register-btn::attr(href), a[data-track='register']::attr(href)"
        ).get("")
        item["official_website"] = response.css(
            "a.website, .official-site::attr(href)"
        ).get("")
        item["venue"] = item["venue"] or response.css(
            ".venue-address::text, .location-detail::text"
        ).get("").strip()
        yield item

    def _parse_dates(self, text):
        if not text:
            return None, None
        try:
            parts = text.replace("–", "-").split("-")
            if len(parts) == 2:
                start = datetime.strptime(parts[0].strip(), "%d %b %Y")
                end = datetime.strptime(parts[1].strip(), "%d %b %Y")
                return start, end
            date = datetime.strptime(text.strip(), "%d %b %Y")
            return date, date
        except ValueError:
            return None, None
