from pydantic_settings import BaseSettings, SettingsConfigDict


class BrokerSettings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix='rabbitmq_')
    user: str
    password: str
    host: str
    port: int
    queue: str
