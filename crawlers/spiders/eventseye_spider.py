import scrapy
from datetime import datetime
from urllib.parse import urljoin
from crawlers.items import ExhibitionItem


class EventsEyeSpider(scrapy.Spider):
    name = "eventseye"
    allowed_domains = ["eventseye.com"]
    start_urls = ["https://www.eventseye.com/fairs/"]

    custom_settings = {
        "DOWNLOAD_DELAY": 1.0,
        "CONCURRENT_REQUESTS": 12,
    }

    def parse(self, response):
        for row in response.css("table.fair-table tr, .fair-list-item"):
            item = ExhibitionItem()
            item["source"] = "EventsEye"
            link = row.css("a::attr(href)").get()
            if not link:
                continue
            item["source_url"] = urljoin(response.url, link)
            item["name"] = row.css("a::text, .fair-name::text").get("").strip()
            item["country"] = row.css(".country::text, td:nth-child(2)::text").get("").strip()
            item["city"] = row.css(".city::text, td:nth-child(3)::text").get("").strip()
            date_text = row.css(".date::text, td:nth-child(4)::text").get("")
            item["start_date"], item["end_date"] = self._parse_dates(date_text)
            item["industries"] = [row.css(".industry::text, td:nth-child(5)::text").get("").strip()] if row.css(".industry::text, td:nth-child(5)::text") else []
            item["venue"] = row.css(".venue::text").get("").strip()

            yield scrapy.Request(
                url=item["source_url"],
                callback=self.parse_detail,
                cb_kwargs={"item": item},
                dont_filter=True,
            )

        next_page = response.css("a.next::attr(href), .pagination a:contains('Next')::attr(href)").get()
        if next_page:
            yield response.follow(next_page, self.parse)

    def parse_detail(self, response, item):
        item["description"] = response.css(
            ".description p::text, [itemprop='description'] p::text"
        ).get("").strip()
        item["organizer"] = response.css(
            ".organizer::text, [itemprop='organizer']::text"
        ).get("").strip()
        item["registration_url"] = response.css(
            "a.register::attr(href), .registration-link::attr(href)"
        ).get("")
        item["official_website"] = response.css(
            "a.website::attr(href), [itemprop='url']::attr(href)"
        ).get("")
        item["exhibitors_count"] = response.css(
            ".exhibitors-count::text, [itemprop='exhibitors']::text"
        ).re_first(r"[\d,]+")
        item["visitors_count"] = response.css(
            ".visitors-count::text, [itemprop='visitors']::text"
        ).re_first(r"[\d,]+")
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
