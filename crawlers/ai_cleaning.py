"""
FairConnect AI Data Cleaning Module (Phase 3)

Handles:
- Summarization of exhibition descriptions
- Industry categorization
- SEO keyword generation
- Duplicate detection
"""

import logging
import re
from typing import Optional

logger = logging.getLogger(__name__)

INDUSTRY_KEYWORDS = {
    "Technology": [
        "tech", "software", "hardware", "ai", "artificial intelligence",
        "blockchain", "cyber", "it ", "digital", "computing", "iot",
        "saas", "cloud", "robotics", "semiconductor", "electronics",
    ],
    "Healthcare": [
        "health", "medical", "pharma", "biotech", "clinical", "hospital",
        "dental", "healthcare", "wellness", "nursing", "diagnostic",
    ],
    "Automotive": [
        "auto", "automotive", "vehicle", "car ", "ev ", "electric vehicle",
        "transportation", "mobility", "truck", "motor",
    ],
    "Agriculture": [
        "agriculture", "agri", "farm", "food production", "crop",
        "farming", "horticulture", "aquaculture", "veterinary",
    ],
    "Energy": [
        "energy", "power", "renewable", "solar", "wind", "petroleum",
        "oil ", "gas ", "nuclear", "electricity", "sustainability",
        "clean energy", "hydrogen", "battery",
    ],
    "Fashion": [
        "fashion", "textile", "apparel", "clothing", "garment", "style",
        "leather", "footwear", "jewelry", "accessories", "runway",
    ],
    "Food & Beverage": [
        "food", "beverage", "drink", "wine", "beer", "restaurant",
        "culinary", "bakery", "confectionery", "organic food",
    ],
    "Education": [
        "education", "learning", "training", "school", "university",
        "e-learning", "edtech", "academic", "student", "college",
    ],
    "Real Estate": [
        "real estate", "property", "construction", "building", "architecture",
        "housing", "commercial", "infrastructure", "urban development",
    ],
    "Aerospace": [
        "aerospace", "aviation", "airline", "airport", "space", "defense",
        "aeronautics", "satellite", "drone", "flying",
    ],
}


def categorize_industries(
    name: str,
    description: str,
    existing_industries: Optional[list[str]] = None,
) -> list[str]:
    try:
        text = f"{name} {description}".lower()
        matched = []
        for industry, keywords in INDUSTRY_KEYWORDS.items():
            for kw in keywords:
                if kw in text:
                    matched.append(industry)
                    break
        existing = existing_industries or []
        combined = list(dict.fromkeys(existing + matched))
        return combined if combined else ["General"]
    except Exception as e:
        logger.error(f"Industry categorization failed: {e}")
        return existing_industries or ["General"]


def generate_seo_keywords(
    name: str,
    description: str,
    industries: Optional[list[str]] = None,
    country: str = "",
) -> list[str]:
    try:
        keywords = set()
        text = f"{name} {description}"

        industry_tag = industries[0] if industries else "Trade"
        keywords.add(f"{industry_tag} Exhibition")
        if country:
            keywords.add(f"{country} {industry_tag} Fair")
            keywords.add(f"Trade Show in {country}")
        keywords.add(f"{name}")
        keywords.add(f"{industry_tag} Trade Fair")

        words = re.findall(r"[A-Z][a-z]+", name)
        for w in words[:3]:
            keywords.add(f"{w} Exhibition")

        return list(keywords)[:10]
    except Exception as e:
        logger.error(f"SEO keyword generation failed: {e}")
        return []


def generate_summary(description: str, max_sentences: int = 3) -> str:
    try:
        if not description:
            return ""

        sentences = re.split(r"(?<=[.!?])\s+", description.strip())
        sentences = [s.strip() for s in sentences if len(s.strip()) > 20]

        if not sentences:
            return description[:200]

        return " ".join(sentences[:max_sentences])
    except Exception as e:
        logger.error(f"Summary generation failed: {e}")
        return description[:200] if description else ""


def detect_duplicates(
    name: str, city: str, existing_names: list[str]
) -> Optional[str]:
    try:
        name_lower = name.lower().strip()
        name_clean = re.sub(r"[^a-z0-9\s]", "", name_lower)

        for existing in existing_names:
            existing_lower = existing.lower().strip()
            existing_clean = re.sub(r"[^a-z0-9\s]", "", existing_lower)

            if name_clean == existing_clean:
                return existing

            name_words = set(name_clean.split())
            existing_words = set(existing_clean.split())
            if len(name_words & existing_words) >= 3 and city:
                return existing

        return None
    except Exception as e:
        logger.error(f"Duplicate detection failed: {e}")
        return None


def clean_exhibition_data(data: dict) -> dict:
    if data.get("industries") is None or not data["industries"]:
        data["industries"] = categorize_industries(
            data.get("name", ""),
            data.get("description", ""),
        )

    if data.get("tags") is None or not data["tags"]:
        data["tags"] = generate_seo_keywords(
            data.get("name", ""),
            data.get("description", ""),
            data.get("industries"),
            data.get("country", ""),
        )

    if data.get("description") and len(data.get("description", "")) > 300:
        data["summary"] = generate_summary(data["description"])

    return data
