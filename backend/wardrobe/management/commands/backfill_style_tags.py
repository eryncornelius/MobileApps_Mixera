"""
Management command: backfill_style_tags

Fills empty style_tags on DetectedItemCandidate and WardrobeItem rows
using data already present in ai_raw_response / source_candidate.

Usage:
    python manage.py backfill_style_tags            # dry-run (no writes)
    python manage.py backfill_style_tags --apply    # actually save
"""
from django.core.management.base import BaseCommand

from wardrobe.models import DetectedItemCandidate, WardrobeItem


class Command(BaseCommand):
    help = "Backfill empty style_tags from ai_raw_response (candidates) and source_candidate (wardrobe items)."

    def add_arguments(self, parser):
        parser.add_argument(
            "--apply",
            action="store_true",
            help="Write changes to the database. Omit to do a dry-run.",
        )

    def handle(self, *args, **options):
        apply = options["apply"]
        mode = "APPLY" if apply else "DRY-RUN"
        self.stdout.write(f"[{mode}] Starting style_tags backfill...\n")

        candidate_fixed = self._backfill_candidates(apply)
        item_fixed = self._backfill_wardrobe_items(apply)

        self.stdout.write(
            self.style.SUCCESS(
                f"\n[{mode}] Done. "
                f"Candidates fixed: {candidate_fixed}, "
                f"WardrobeItems fixed: {item_fixed}."
            )
        )
        if not apply:
            self.stdout.write("  Run with --apply to write changes.\n")

    # ------------------------------------------------------------------

    def _backfill_candidates(self, apply: bool) -> int:
        qs = DetectedItemCandidate.objects.filter(style_tags=[])
        total = qs.count()
        self.stdout.write(f"  Candidates with empty style_tags: {total}")

        fixed = 0
        for candidate in qs.iterator():
            raw = candidate.ai_raw_response or {}
            tags = raw.get("style_tags", [])
            if not (isinstance(tags, list) and tags):
                continue  # AI also returned nothing — skip

            parsed = [str(t) for t in tags if isinstance(t, str)]
            if not parsed:
                continue

            self.stdout.write(f"    Candidate #{candidate.pk}: {parsed}")
            if apply:
                candidate.style_tags = parsed
                candidate.save(update_fields=["style_tags"])
            fixed += 1

        return fixed

    def _backfill_wardrobe_items(self, apply: bool) -> int:
        qs = WardrobeItem.objects.filter(style_tags=[]).select_related("source_candidate")
        total = qs.count()
        self.stdout.write(f"  WardrobeItems with empty style_tags: {total}")

        fixed = 0
        for item in qs.iterator():
            candidate = item.source_candidate
            if not candidate:
                continue

            # Use candidate's style_tags if already backfilled, else fall back to raw
            tags = candidate.style_tags
            if not tags:
                raw = candidate.ai_raw_response or {}
                tags = raw.get("style_tags", [])

            if not (isinstance(tags, list) and tags):
                continue

            parsed = [str(t) for t in tags if isinstance(t, str)]
            if not parsed:
                continue

            self.stdout.write(f"    WardrobeItem #{item.pk}: {parsed}")
            if apply:
                item.style_tags = parsed
                item.save(update_fields=["style_tags"])
            fixed += 1

        return fixed
