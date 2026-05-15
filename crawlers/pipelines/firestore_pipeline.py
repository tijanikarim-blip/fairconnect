import logging
import os
from datetime import datetime, timezone
from uuid import uuid4

import firebase_admin
from firebase_admin import credentials, firestore

logger = logging.getLogger(__name__)


class FirestorePipeline:
    def open_spider(self, spider):
        try:
            firebase_admin.get_app()
        except ValueError:
            cred_path = os.getenv("FIREBASE_CREDENTIALS")
            if cred_path and os.path.exists(cred_path):
                cred = credentials.Certificate(cred_path)
                firebase_admin.initialize_app(cred)
            else:
                firebase_admin.initialize_app()

        self.db = firestore.client()
        self.collection = self.db.collection("exhibitions")
        self.stats = {"added": 0, "updated": 0, "skipped": 0}

    def close_spider(self, spider):
        logger.info(
            f"[{spider.name}] FirestorePipeline stats: "
            f"added={self.stats['added']}, "
            f"updated={self.stats['updated']}, "
            f"skipped={self.stats['skipped']}"
        )

    def process_item(self, item, spider):
        slug = item.get("slug", "")
        existing = self._find_by_slug(slug)

        doc_data = self._build_doc(item)

        if existing:
            existing_ref = self.collection.document(existing.id)
            existing_ref.update({**doc_data, "last_verified_at": datetime.now(timezone.utc)})
            self.stats["updated"] += 1
        else:
            doc_id = str(uuid4())
            self.collection.document(doc_id).set({
                **doc_data,
                "id": doc_id,
                "created_at": datetime.now(timezone.utc),
                "last_verified_at": datetime.now(timezone.utc),
            })
            self.stats["added"] += 1

        return item

    def _find_by_slug(self, slug):
        if not slug:
            return None
        docs = self.collection.where("slug", "==", slug).limit(1).get()
        return docs[0] if docs else None

    def _build_doc(self, item):
        return {
            "name": item.get("name", ""),
            "slug": item.get("slug", ""),
            "description": item.get("description", ""),
            "industries": item.get("industries", []),
            "industry": (item.get("industries") or [None])[0] or "",
            "country": item.get("country", ""),
            "city": item.get("city", ""),
            "venue": item.get("venue", ""),
            "startDate": item.get("start_date"),
            "endDate": item.get("end_date"),
            "official_website": item.get("official_website", ""),
            "website": item.get("official_website", ""),
            "registration_url": item.get("registration_url", ""),
            "registrationUrl": item.get("registration_url", ""),
            "youtube_video_url": item.get("youtube_video_url"),
            "youtubeVideoId": item.get("youtube_video_url"),
            "images": item.get("images", []),
            "imageUrl": (item.get("images") or [None])[0],
            "exhibitors_count": item.get("exhibitors_count"),
            "visitors_count": item.get("visitors_count"),
            "tags": item.get("tags", []),
            "languages": item.get("languages", []),
            "organizer": item.get("organizer", ""),
            "isPremium": item.get("is_premium", False),
            "isFeatured": item.get("is_featured", False),
            "source": item.get("source", ""),
            "source_url": item.get("source_url", ""),
        }
