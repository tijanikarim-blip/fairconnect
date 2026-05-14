import scrapy
from datetime import datetime
from urllib.parse import urljoin
from crawlers.items import ExhibitionItem


class UfiSpider(scrapy.Spider):
    name = "ufi"
    allowed_domains = ["ufi.org"]
    start_urls = ["https://www.ufi.org/membership/ufi-member-directory/"]

    custom_settings = {
        "DOWNLOAD_DELAY": 3.0,
        "CONCURRENT_REQUESTS": 4,
    }

    def parse(self, response):
        for card in response.css(".member-item, .directory-item, .event-item"):
            item = ExhibitionItem()
            item["source"] = "UFI"
            link = card.css("a::attr(href)").get()
            if not link:
                continue
            item["source_url"] = urljoin(response.url, link)
            item["name"] = card.css("h3::text, .member-name::text, .event-title::text").get("").strip()
            item["organizer"] = card.css(".organizer::text, .member-org::text").get("").strip()
            item["country"] = card.css(".country::text, .location::text").get("").strip()
            item["city"] = card.css(".city::text").get("").strip()
            item["industries"] = card.css(".sector::text, .industry-tag::text").getall()

            if link:
                yield scrapy.Request(
                    url=item["source_url"],
                    callback=self.parse_detail,
                    cb_kwargs={"item": item},
                    dont_filter=True,
                )

    def parse_detail(self, response, item):
        item["description"] = response.css(
            ".description p::text, .member-description p::text, [data-section='about'] p::text"
        ).get("").strip()
        item["official_website"] = response.css(
            "a.website::attr(href), .member-site::attr(href)"
        ).get("")
        item["venue"] = response.css(
            ".venue::text, .address::text"
        ).get("").strip()
        date_text = response.css(
            ".date::text, .event-dates::text"
        ).get("")
        item["start_date"], item["end_date"] = self._parse_dates(date_text)
        yield item

    def _parse_dates(self, text):
        if not text:
            return None, None
        try:
            text = text.replace("–", "-").replace("\u2013", "-")
            parts = text.split("-")
            if len(parts) == 2:
                start = datetime.strptime(parts[0].strip(), "%d %B %Y")
                end = datetime.strptime(parts[1].strip(), "%d %B %Y")
                return start, end
            date = datetime.strptime(text.strip(), "%d %B %Y")
            return date, date
        except ValueError:
            return None, None
