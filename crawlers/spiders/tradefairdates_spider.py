import scrapy
from datetime import datetime
from urllib.parse import urljoin
from crawlers.items import ExhibitionItem


class TradeFairDatesSpider(scrapy.Spider):
    name = "tradefairdates"
    allowed_domains = ["tradefairdates.com"]
    start_urls = ["https://www.tradefairdates.com/"]

    custom_settings = {
        "DOWNLOAD_DELAY": 1.5,
        "CONCURRENT_REQUESTS": 10,
    }

    def parse(self, response):
        for link in response.css("a[href*='/trade-shows/']::attr(href)").getall()[:50]:
            yield scrapy.Request(
                url=urljoin(response.url, link),
                callback=self.parse_listing,
            )

    def parse_listing(self, response):
        for card in response.css(".show-card, .trade-show-item, .event-item"):
            item = ExhibitionItem()
            item["source"] = "TradeFairDates"
            link = card.css("a::attr(href)").get()
            item["source_url"] = urljoin(response.url, link) if link else response.url
            item["name"] = card.css("h2 a::text, h3 a::text, .show-title::text").get("").strip()
            item["country"] = card.css(".country::text, .location span:first-child::text").get("").strip()
            item["city"] = card.css(".city::text, .location span:nth-child(2)::text").get("").strip()
            date_text = card.css(".date::text, .event-date::text").get("")
            item["start_date"], item["end_date"] = self._parse_dates(date_text)
            item["industries"] = card.css(".category::text, .sector::text").getall()

            if link:
                yield scrapy.Request(
                    url=item["source_url"],
                    callback=self.parse_detail,
                    cb_kwargs={"item": item},
                    dont_filter=True,
                )

        next_page = response.css("a.next::attr(href), .pagination a:contains('Next')::attr(href)").get()
        if next_page:
            yield response.follow(next_page, self.parse_listing)

    def parse_detail(self, response, item):
        item["description"] = response.css(
            ".description p::text, #event-description p::text"
        ).get("").strip()
        item["venue"] = response.css(
            ".venue::text, .location-detail::text"
        ).get("").strip()
        item["organizer"] = response.css(
            ".organizer::text, .organized-by::text"
        ).get("").strip()
        item["registration_url"] = response.css(
            "a.register::attr(href), .btn-register::attr(href)"
        ).get("")
        item["official_website"] = response.css(
            "a.website::attr(href), .official-link::attr(href)"
        ).get("")
        yield item

    def _parse_dates(self, text):
        if not text:
            return None, None
        try:
            text = text.replace("–", "-").replace("\u2013", "-")
            parts = text.split("-")
            if len(parts) == 2:
                start = datetime.strptime(parts[0].strip(), "%d %b %Y")
                end = datetime.strptime(parts[1].strip(), "%d %b %Y")
                return start, end
            date = datetime.strptime(text.strip(), "%d %b %Y")
            return date, date
        except ValueError:
            return None, None
