from faststream import FastStream
from faststream.rabbit import RabbitBroker, RabbitQueue

from settings.broker import BrokerSettings

db_settings = DBSettings()
broker_settings = BrokerSettings()

broker = RabbitBroker(
    f"amqp://{broker_settings.user}:{broker_settings.password}@{broker_settings.host}:{broker_settings.port}/",
    max_consumers=2, graceful_timeout=25)

app = FastStream(broker)
queue = RabbitQueue(name=broker_settings.queue)


@broker.subscriber(queue)
async def say_hello(message: str):
    print(f'Hello: {message}')