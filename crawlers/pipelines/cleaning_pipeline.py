import re
import logging
from datetime import datetime

logger = logging.getLogger(__name__)


class CleaningPipeline:
    def process_item(self, item, spider):
        self._clean_text_fields(item)
        self._clean_dates(item)
        self._clean_numbers(item)
        self._clean_lists(item)
        self._generate_slug(item)
        return item

    def _clean_text_fields(self, item):
        for field in ["name", "description", "venue", "organizer", "city", "country"]:
            if item.get(field):
                item[field] = re.sub(r"\s+", " ", item[field]).strip()

        for field in ["official_website", "registration_url", "youtube_video_url"]:
            if item.get(field):
                item[field] = item[field].strip()

    def _clean_dates(self, item):
        for field in ["start_date", "end_date"]:
            val = item.get(field)
            if val and isinstance(val, str):
                try:
                    item[field] = datetime.fromisoformat(val.replace("Z", "+00:00"))
                except (ValueError, TypeError):
                    logger.warning(f"Could not parse date: {val}")
                    item[field] = None

    def _clean_numbers(self, item):
        for field in ["exhibitors_count", "visitors_count"]:
            val = item.get(field)
            if val is not None:
                try:
                    item[field] = int(re.sub(r"[^0-9]", "", str(val)))
                except (ValueError, TypeError):
                    item[field] = None

    def _clean_lists(self, item):
        for field in ["industries", "tags", "languages", "images"]:
            val = item.get(field)
            if isinstance(val, str):
                item[field] = [v.strip() for v in val.split(";") if v.strip()]
            elif val is None:
                item[field] = []

    def _generate_slug(self, item):
        name = item.get("name", "")
        slug = name.lower()
        slug = re.sub(r"[^a-z0-9\s-]", "", slug)
        slug = re.sub(r"\s+", "-", slug)
        slug = re.sub(r"-+", "-", slug)
        item["slug"] = slug.strip("-")
