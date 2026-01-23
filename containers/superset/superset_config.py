import os

from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization

SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY")
WTF_CSRF_ENABLED = True
FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True
}


def DB_CONNECTION_MUTATOR(uri, params, username, security_manager, source):
    """
    Intercepts the DB connection.
    If it's Snowflake, inject the Private Key object.
    """
    # Check if the driver is Snowflake
    if uri.drivername == "snowflake":
        private_key_path = os.environ.get("SNOWFLAKE_PRIVATE_KEY_PATH")

        if private_key_path and os.path.exists(private_key_path):
            print(f"Loading Snowflake Private Key from {private_key_path}...")

            with open(private_key_path, "rb") as key_file:
                p_key = serialization.load_pem_private_key(
                    key_file.read(),
                    password=None,  # Assuming unencrypted PKCS8
                    backend=default_backend()
                )

            # Inject the key object into the connection arguments
            # This 'connect_args' is passed directly to the snowflake-python-connector
            if "connect_args" not in params:
                params["connect_args"] = {}

            params["connect_args"]["private_key"] = p_key
            print("Snowflake Private Key injected successfully.")

    return uri, params
