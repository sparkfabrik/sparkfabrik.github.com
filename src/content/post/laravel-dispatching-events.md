+++
date = "2021-06-29T14:44:41Z"
draft = true
title = "Dispatching Events in Laravel"
tags  = ['laravel', 'events', 'backend', 'api']
slug  = 'laravel-dispatching-events'
+++

# Intro

We've been using Laravel in one of our long term projects as an API backend, and we've found that its Event layer became more useful as development went on and the project grew in complexity. The earlier you design and utilize the Event layer, the more you can decouple the various processes within your application, and development will become far more manageable.

Laravel's Event layer is a basic event and listener system. Listener and Event classes are stored in their respective app/Listener and app/Events directories

# Why use Events?

Events are a fantastic way of decoupling actions and business logic, removing complexity and spaghetti code. 

I'll start with an example of a problem we encountered recently which was solved with an Event. Within one of our service classes, we needed to update the names of all of a Shop's products whenever the shop itself changed name. We had a ShopService, which updated the Shop's name, and a ProductService. 

The ProductService was already initializing the ShopService within its constructor, and so initialising the ShopService within the ProductService's constructor would cause an infinite loop and rightfully die on execution.

The solution was create an Event whenever a Shop's name was updated, with a listener that would update the names of all products within that shop. 

Laravel's handy CLI Artisan allows for easy generation of Events and Listeners classes with the following commands:

`php artisan make:event ShopUpdated`

`php artisan make:listener UpdateProductName --event ShopUpdated`

These classes should now be bound to each other within `listen` array of the EventServiceProvider class found under the `app/Providers` directory:

```php
ShopUpdated::class => [ // Event
    UpdateProductName::class, // Listener
],
```

Remember that an Event can have multiple listeners, and a listener can subscribe to many events:

```php
ShopUpdated::class => [ // Event
    UpdateProductName::class, // Listener
    UpdateProductPrice::class, // Listener
],
```

# Defining the Event & Listener classes

Events are simple classes which define the information related to an Event. Usually they contain no logic, in our example it is a container for the `Shop` model with the `Dispatchable` (a helper to dispatch the event without needing to instantiate it within your service), and the `SerializesModels` (a helepr which uses PHP's `serialize` function to serialize the Eloquent model) traits.


```php
namespace App\Events;

use App\Models\Shop;
use Illuminate\Queue\SerializesModels;
use Illuminate\Foundation\Events\Dispatchable;

class ShopUpdated
{
    use Dispatchable, SerializesModels;

    public $shop;

    /**
     * Create a new event instance.
     *
     * @return void
     */
    public function __construct(Shop $shop)
    {
        $this->shop = $shop;
    }
}
```

The Listener class executes the code you expect to occur when an Event is triggered. The class should receive an instance of the `ShopEvent` within its `handle` method.


```php
namespace App\Listeners;

use App\Events\ShopUpdated;
use App\Models\TravelOption;
use App\Services\Interfaces\ProductServiceInterface;
use Illuminate\Contracts\Queue\ShouldQueue;

class ChangeProductName implements ShouldQueue
{
    private $productService;

    /**
     * Create the event listener.
     *
     * @return void
     */
    public function __construct(
        ProductServiceInterface $productService
    ) {
        $this->productService = $productService;
    }

    /**
     * Handle the event.
     *
     * @param ProductSaved $event
     * @return void
     */
    public function handle(ShopUpdated $event)
    {
        $shop = $event->shop;
        $products = $shop->products()->get();

        $products->each(function ($product) use ($shop) {
            $product->name = $this->productService->constructName($shop);
            $product->save();
        });

        return;
    }
}
```

# Dispatching Events

This is done simply by calling the `dispatch` static method of the event (Laravel 8. For other versions of Laravel, you have to pass an instance of the event). In our case, we want to dispatch the event within the `edit` method of our `ShopService` when the shop's name is changed:


** Laravel > 8 **
```php
if ($request->get('name')) {
    ShopUpdated::dispatch($shop);        
}
```

** Laravel < 8 **
```php
if ($request->get('name')) {
    event(new ShopUpdated($shop));
}
```

# Testing Events

Performing unit tests against Events is also pain free. We used PHPUnit as our testing library, default for Laravel. 

A usual test would follow these steps:

* Assert the Listener is subscribed to your Event:
```php
Event::assertListening(
    ShopUpdated::class,
    ChangeProductName::class
);
```

* Dispatch the event
* Assert the event was dispatched:
```php
Event::assertDispatched(ShopUpdated::class)
```

* Perform assertions against your Model to confirm the `handle` method of the listener did as you expected:
```php
$this->assertEquals($product, "updated name")
```

If instead you'd prefer to mock an event, preventing it the listener from executing, use the `faker` action of Laravel's `Event` helper class. Note that the event will still be dispatched.

`Event::fake()`

`Event::assertDispatched(OrderShipped::class)`
`true`

See more about Mocking in Laravel on the official documentation: https://laravel.com/docs/8.x/mocking

# Conclusion

That's it! Events are a great Laravel feature to decouple processes within your application. When designing a project consider the Events layer from the start. Think about it from a user perspective; if something happens to an entity, and you expect an action to occur: make it an Event!




