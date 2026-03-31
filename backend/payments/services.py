import base64

import requests
from django.conf import settings


class MidtransService:
    @staticmethod
    def _base_url():
        return (
            "https://app.midtrans.com"
            if settings.MIDTRANS_IS_PRODUCTION
            else "https://app.sandbox.midtrans.com"
        )

    @staticmethod
    def _api_base_url():
        return (
            "https://api.midtrans.com"
            if settings.MIDTRANS_IS_PRODUCTION
            else "https://api.sandbox.midtrans.com"
        )

    @staticmethod
    def _headers():
        server_key = settings.MIDTRANS_SERVER_KEY
        auth_string = base64.b64encode(f"{server_key}:".encode()).decode()
        return {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": f"Basic {auth_string}",
        }

    @classmethod
    def create_snap_transaction(cls, payload: dict):
        try:
            response = requests.post(
                f"{cls._base_url()}/snap/v1/transactions",
                json=payload,
                headers=cls._headers(),
                timeout=20,
            )
            response.raise_for_status()
            return response.json()
        except requests.HTTPError as exc:
            detail = exc.response.text if exc.response is not None else str(exc)
            raise Exception(f"Midtrans Snap error: {detail}") from exc
        except requests.RequestException as exc:
            raise Exception(f"Midtrans unreachable: {exc}") from exc

    @classmethod
    def charge_card(cls, payload: dict):
        """
        Core API card charge.
        payload must include: payment_type='credit_card',
        transaction_details, and credit_card.token_id
        (either a one-time Midtrans.js token or a saved_token_id).
        """
        try:
            response = requests.post(
                f"{cls._api_base_url()}/v2/charge",
                json=payload,
                headers=cls._headers(),
                timeout=20,
            )
            response.raise_for_status()
            return response.json()
        except requests.HTTPError as exc:
            detail = exc.response.text if exc.response is not None else str(exc)
            raise Exception(f"Midtrans Core API error: {detail}") from exc
        except requests.RequestException as exc:
            raise Exception(f"Midtrans unreachable: {exc}") from exc

    @classmethod
    def get_transaction_status(cls, order_id: str):
        try:
            response = requests.get(
                f"{cls._api_base_url()}/v2/{order_id}/status",
                headers=cls._headers(),
                timeout=20,
            )
            response.raise_for_status()
            return response.json()
        except requests.HTTPError as exc:
            detail = exc.response.text if exc.response is not None else str(exc)
            raise Exception(f"Midtrans status error: {detail}") from exc
        except requests.RequestException as exc:
            raise Exception(f"Midtrans unreachable: {exc}") from exc

    @staticmethod
    def client_key():
        return settings.MIDTRANS_CLIENT_KEY
