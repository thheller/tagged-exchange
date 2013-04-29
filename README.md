# RabbitMQ Tagged Exchange Type

Routes messages based on tags. Random 1 hour hack without knowing anything about RabbitMQ. So better be careful, its probably buggy.

### Installation

    git clone git://github.com/thheller/tagged-exchange.git
    cd tagged-exchange
    make package
    cp dist/*.ez $RABBITMQ_HOME/plugins

### Usage

To use it, declare an exchange of type "tagged".

    Apache 2.0 Licensed:
    http://www.apache.org/licenses/LICENSE-2.0.html

### Special Thanks

I basically cloned https://github.com/jbrisbin/random-exchange and just renamed the relevant bits, so thanks @jbrisbin for rebar-ing everything.
