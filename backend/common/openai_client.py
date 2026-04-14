"""Shared OpenAI client factory.

Usage (from any app):
    from common.openai_client import get_openai_client
    client = get_openai_client()
    # client is an openai.OpenAI instance
"""
import logging

logger = logging.getLogger(__name__)

_client = None  # module-level singleton, initialised lazily


def image_edit_supports_input_fidelity_high(model: str) -> bool:
    """
    Whether ``client.images.edit(..., input_fidelity='high')`` is accepted for this model.

    OpenAI returns 400 ``invalid_input_fidelity_model`` for e.g. ``gpt-image-1-mini``.
    """
    m = (model or "").lower()
    if "mini" in m:
        return False
    return "gpt-image-1.5" in m


def get_openai_client():
    """
    Return a shared openai.OpenAI instance, created once per process.

    Raises:
        RuntimeError if OPENAI_API_KEY is not set.
        ImportError  if the openai package is not installed.
    """
    global _client
    if _client is not None:
        return _client

    try:
        import openai
    except ImportError as exc:
        raise ImportError(
            "The 'openai' package is not installed. "
            "Run: pip install openai"
        ) from exc

    from django.conf import settings

    api_key = getattr(settings, "OPENAI_API_KEY", "")
    if not api_key:
        raise RuntimeError(
            "OPENAI_API_KEY is not set. Add it to your .env file."
        )

    _client = openai.OpenAI(api_key=api_key)
    logger.debug("OpenAI client initialised (model: %s)", getattr(settings, "OPENAI_MODEL", "?"))
    return _client
