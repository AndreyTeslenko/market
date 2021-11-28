# Market

Library for calculating discount on products groups or one type of product by flexible conditions

## Usage

Suppose you have some store and you want to provide some discounts on some product group by some conditions. With this library you can define a conditions of discount, calculate discount and apply it on the products from the basket.

For example you have products
| Code | Name | Price |
| ----------- | ----------- | ----------- |
| gt | Green Tea | 3.11 |
| sr | Strawberry | 5 |
| cf | Coffee | 11.23 |

Let's create them

```elixir
iex> {:ok, green_tea} = Market.create_product("gt", "Green Tea", 3.11)
{:ok, %Product{code: "gt", name: "Green Tea", price: 3.11}}

iex> {:ok, strawberry} = Market.create_product("gt", "Green Tea", 5)
{:ok, %Product{code: "sr", name: "Strawberry", price: 5}}

iex> {:ok, coffee} = Market.create_product("gt", "Green Tea", 11.23)
{:ok, %Product{code: "cf", name: "Coffee", price: 11.23}}
```

And use them to simulate a customer use case. Let's imagine that the customer adds some of this products to the basket:

```elixir
iex> basket = Market.create_basket([strawberry])
{:ok,
  %Basket{
    products: [
      %Product{code: "sr", name: "Strawberry", price: 5}
    ],
    total_price: 5
  }
}
```

And adds few more products

```elixir
iex> basket = Market.add_product_to_basket(basket, coffee)
iex> basket = Market.add_product_to_basket(basket, strawberry)
iex> basket = Market.add_product_to_basket(basket, green_tea)
{:ok,
  %Basket{
    products: [
      %Product{code: "sr", name: "Strawberry", price: 5},
      %Product{code: "cf", name: "Coffee", price: 11.23},
      %Product{code: "sr", name: "Strawberry", price: 5},
      %Product{code: "gt", name: "Green Tea", price: 3.11}
    ],
    total_price: 24.34
  }
}
```

So we have some list of product in the basket. Time to create some discount.

First of all you need to develop some rule for the discount.

> For example you want to decrease price for `strawberry` on 50% if in the basket more than one.

For creating a valid rule you need following next:

- Split your rule on the condition part and calculation part.
- Build a condition function - `(products_groups_count -> boolean())`, where `products_groups_count` is total found products groups according to `target group`
- Build a calc function - `(products_groups_count, group_base_price -> number())`

Take a look an example:

```
We have products in a basket - [sr, gt, sr, cf sr, gt]
We define a target group - [sr, gt]

In this case
products_groups_count = 2
group_base_price = (sr.price + gt.price) * products_groups_count
```

So knowing that, you can create functions according to our case

```elixir
iex> condition_func = fn products_count -> products_count > 1 end

iex> calc_func = fn products_count, base_price ->
...>   products_count * base_price/2
...> end
```

And then create a rule:

```elixir
iex> {:ok, rule} = Market.create_rule(condition_func, calc_func)
{:ok, %Rule{applicable?: condition_func, calculate_discounted_total: calc_func}}
```

Finally, you can create a new discount for `strawberry` and apply it on the products in the basket

```elixir
iex> rules = [rule]
iex> target_group = [strawberry]
iex> {:ok, discount} = Market.create_discount(target_group, rules)
%Market.Discounts.Discount{
  target_group: [
    %Product{code: "sr", name: "Strawberry", price: 5}
  ],
  rules: [
    %Rule{applicable?: condition_func, calculate_discounted_total: calc_func}
  ],
  group_base_price: 5
 }
```

> Reminder what the products we have in the basket \
> [Strawberry, Coffee, Strawberry, Green tea] - total price without discount is £24.34

```elixir
iex> discounts = [discount]
iex> Market.calculate_price_with_discount(basket, discounts)
"£19.34"
```

That's it. What next?

## Other cases

> What if you need more than one rule for some group of products?

No problem, you can create as many rules as you want

```elixir
iex> rules = [rule1, rule2, rule3]
iex> target_group = [strawberry]
iex> {:ok, discount} = Market.create_discount(target_group, rules)
%Market.Discounts.Discount{
  target_group: [
    %Product{code: "sr", name: "Strawberry", price: 5}
  ],
  rules: [
    %Rule{applicable?: condition_func, calculate_discounted_total: calc_func}
    %Rule{applicable?: condition_func, calculate_discounted_total: calc_func}
    %Rule{applicable?: condition_func, calculate_discounted_total: calc_func}
  ],
  group_base_price: 5
 }
```

> What if you need create discount on more than one product?

You can create target group with one or more products

```elixir
iex> rules = [rule1]
iex> target_group = [strawberry, green_tea]
iex> {:ok, discount} = Market.create_discount(target_group, rules)
%Market.Discounts.Discount{
  target_group: [
    %Product{code: "sr", name: "Strawberry", price: 5},
    %Product{code: "gt", name: "Green Tea", price: 3.11}
  ],
  rules: [
    %Rule{applicable?: condition_func, calculate_discounted_total: calc_func}
    %Rule{applicable?: condition_func, calculate_discounted_total: calc_func}
    %Rule{applicable?: condition_func, calculate_discounted_total: calc_func}
  ],
  group_base_price: 8.11
 }
```

> If I have the discount with many rules and all of them are applicable on current set of products, which one will be applied?

In this case, will be chosen the rule which has the biggest discount price available on these target products

> What if I try to apply several discounts when target groups of these have the same type of product?

You will receive the error about the conflict of discounts.
