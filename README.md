# Composable Banking App

A sample app written using the Composable Architecture that interacts with the Starling API.

Create a project + sandbox account here -> https://developer.starlingbank.com. (You should simulate some transactions once you have a test sandbox user)

I'd say start at `TCABankingApp` -> `RootView` -> `AppContext` and dig around from there is probably the best way to read the code.

If you want to see state changes uncomment the print (line 73) in `AppContext`

* [Features](#features)
* [General notes](#general-notes)
* [Rounding](#rounding)
* [Code Layout](#code-layout)

## Features
- User can login using an access token
- User can select from their accounts
- User can select an end date, and a round up amount will be shown for all outgoing, settled transaction for the week up to that date
- User can save a round up amount for a given period to a savings goal 
    (a single pre-made one, there is no option to make or pick a different savings goal)

### Architecture: [The Composable Architecture(TCA)](https://github.com/pointfreeco/swift-composable-architecture)

TCA is essentially Redux for SwiftUI. It has some nice features for take home exercises like helping making tests easy to write, a dependency container and test stores;
- The concept of Stores is a nice repeatable pattern for building small tested features.
- It comes with a dependency container that allows for implicit contextual dependencies in the environment - not having to set up a coordinator, but still being able to showcase I know how to use dependency injection is useful!
- The TestStore util allows me to write unit tests while getting rid of a huge amount of boilerplate. I discuss this futher in the UI testing section about how this allows unit tests to be so compact.
- Because all state changes and side effects go through a reducer, I can easily print out deltas between the state in one action to another, which helps debugging.

## Rounding

This code is in `RoundingService`, but what follows is an explaination.

This is the code I use;
It first makes sure we aren't comparing currencies of different types (i.e GBP & EUR) because rounding those together would require exchange rate info and a base currency - so I don't support even trying to do that 
```swift
{ amounts in
    let currencySet = Set(amounts.map { $0.currency })
    guard currencySet.count == 1, let currency = currencySet.first else {
        throw RoundingError.mismatchedCurrency
}
```

Next I filter negative values and non/sub normals out - the shouldn't be in the set anyway but better to be safe than sorry
```swift
  let roundUp = amounts
      .filter { $0.toDecimal.isNormal && $0.toDecimal.sign == .plus }
```

Now the main event. I use NSDecimal round to round up my amount which is represented in Decimal, subtracting the amount of the round up from the inital value (e.g; 1.42 -> rounds up to 2.00 so this would give the delta, 58p)
```  swift          
.map { amount in
    var decimal = amount.toDecimal
    var rounded = Decimal()
    NSDecimalRound(&rounded, &decimal, 0, .up)

    return rounded - amount.toDecimal
}
```

Now collect the deltas together to give me the total.
```swift
.reduce(0) {
    $0 + $1
}
```

Then map the round up figure back to the minorUnits by multiplying by 100. Not all currencies use denary so this wouldn't work for those but I left a comment saying I know this. If I had that info from API I could use that here instead of the 100.
```swift    
// Technically this wouldn't work for non-denary currency like Japanese yen, 
// but thats not the problem space I am in for this test, and the API didn't give me a fractional value for currency.
return Amount(currency: currency, minorUnits: (roundUp * 100 as NSDecimalNumber).intValue)
```

Display string + converting minorAmount -> decimal is handled in `Amount+Decimal`

## Code layout

### Services

Anything that handles interaction with an external dependency, be that from a third party API or some system on the Operating System, services are a layer over the messy details that give us data we care about.

Services are registered as dependencies in the same file they are defined.

This practically just means the following small conformances are made in the file;

A `Service` will be;

- A Struct defining it's dependencies, all functions are implemented as closures._
- Have a conformance to `DependencyKey` which requires a `liveValue` implementation. 
- An extension on `DependencyValues` which adds the type to the dependency resolution runtime container.

Then in a seperate file (Typically under `UI Tests/TestDependencies/`) there will be an extension on `Service` implementing the `testValue`, which is automatically swapped out in the test (handled by the ComposableArchitecture framework.)

### Domains

This is where features are defined. For any given feature there is; 
- Clients
- Models - There are mostly generated from QuickType to save time, and worked for the feature, but maybe they've done some weird things defing closed types that aren't actually closed.

### Store

Stores are made up of State, Action, Reducer and dependencies. A store roughly maps to a business domain, like Users or Accounts.

![TCA](https://github.com/pitt500/OnlineStoreTCA/blob/main/Images/TCA_Architecture.png)

### Contexts

A context is a definition conforming to `AppContext`, which in itself is a definition of everything required to make the app run.

There is a `AppContext` configured which is used in the Production app and that context swaps out during texts, which injects mocks so I don't call any real endpoints.

### Views

SwiftUI Views. Views will have a Store, and then the ViewBuilder `WithViewStore` which is used to transform a Store -> ViewStore which means state changes in a store can then be observed by a view. Magic!

Worth noting is how small the views are given how much logic is going on here, I think the Stores encapsulate away anything that isn't presentation nicely!

Worth noting also is that there isn't much benefit putting View level events like typing state and presentation contexts inside the state - you can, but it makes it harder to understand the iOS parts of SwiftUI your view is using. You _can_ do this, but I kept that stuff out of the Stores in favour of making those solely work on business logic + interacting with services. So you have the odd case of a text field @State or @Environment for a presentation in a SwiftUI View, but as I mention its to simplify the stores & views. 

### UI Tests

UI tests.

Using page object pattern I pretty much just test every interaction that you can have with the app. Dependencies are swapped out with stubs at runtime through the Composable Architecture which is why you don't see any setup for that inside the tests - Look inside TCABankingApp to see how the AppContext gets swapped out if its running as a UITest, so all the services get mocked out with test implementations.

### Unit Tests

Unit tests.

Another thing that helps with brevity is that the test store runs test assertions on events, which is perhaps a bit hard to understand without seeing what happens when you mess with the assertions inside the store receive methods, so I suggest you go into a test, for example UserStoreTests and remove line 25 `$0.user = expectedUser` and run the test again. You can see that the receive method itself is asserting the values in the closure are matching what made it through the store - you can't actually take any action on a store without asserting it inside the tests. The state is asserted inside the receive. Do this with any line in the UI tests inside receive to see that it causes the test to fail.

