import scrapy
from datetime import datetime
from urllib.parse import urljoin
from crawlers.items import ExhibitionItem


class TsnnSpider(scrapy.Spider):
    name = "tsnn"
    allowed_domains = ["tsnn.com"]
    start_urls = ["https://www.tsnn.com/trade-shows"]

    custom_settings = {
        "DOWNLOAD_DELAY": 2.0,
        "CONCURRENT_REQUESTS": 6,
    }

    def parse(self, response):
        for card in response.css(".views-row, .tsnn-event, .event-listing"):
            item = ExhibitionItem()
            item["source"] = "TSNN"
            link = card.css("a::attr(href)").get()
            if not link:
                continue
            item["source_url"] = urljoin(response.url, link)
            item["name"] = card.css("h2 a::text, h3 a::text, .event-title::text").get("").strip()
            item["country"] = card.css(".field-country::text, .country::text").get("").strip()
            item["city"] = card.css(".field-city::text, .city::text").get("").strip()
            date_text = card.css(".date-display-single::text, .event-date::text, .field-date::text").get("")
            item["start_date"], item["end_date"] = self._parse_dates(date_text)
            item["industries"] = card.css(".field-industry::text, .industry::text").getall()
            item["venue"] = card.css(".field-venue::text, .venue::text").get("").strip()
            item["organizer"] = card.css(".field-organizer::text, .organizer::text").get("").strip()
            item["description"] = card.css(".field-body::text, .description::text").get("").strip()

            yield item

        next_page = response.css("a[rel='next']::attr(href), .pagination .next a::attr(href)").get()
        if next_page:
            yield response.follow(next_page, self.parse)

    def _parse_dates(self, text):
        if not text:
            return None, None
        try:
            text = text.replace("–", "-").replace("\u2013", "-")
            parts = text.split("-")
            if len(parts) == 2:
                start = datetime.strptime(parts[0].strip(), "%m/%d/%Y")
                end = datetime.strptime(parts[1].strip(), "%m/%d/%Y")
                return start, end
            date = datetime.strptime(text.strip(), "%m/%d/%Y")
            return date, date
        except ValueError:
            try:
                parts = text.split("-")
                if len(parts) == 2:
                    start = datetime.strptime(parts[0].strip(), "%B %d, %Y")
                    end = datetime.strptime(parts[1].strip(), "%B %d, %Y")
                    return start, end
                date = datetime.strptime(text.strip(), "%B %d, %Y")
                return date, date
            except ValueError:
                return None, None
