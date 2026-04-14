from rest_framework.renderers import BaseRenderer


class CsvTextRenderer(BaseRenderer):
    """
    DRF content negotiation: klien dengan ``Accept: text/csv`` butuh renderer
    yang mendeklarasikan ``media_type`` ini; tanpa ini server membalas 406.
    """

    media_type = "text/csv"
    format = "csv"
    charset = "utf-8"

    def render(self, data, accepted_media_type=None, renderer_context=None):
        if data is None:
            return b""
        if isinstance(data, (bytes, bytearray)):
            return bytes(data)
        return str(data).encode(self.charset)
