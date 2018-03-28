CoinWatch is an application to easily see cryptocurrency information
===============

## We have provided a boilerplate application shell, that needs some additional work done.

### Requirements
* Add each coin's current price in Canadian Dollars (CAD) to _both_ the coin table, and the detail page.
* Wiring in the favorite button to the CoreData store: when the user selects the favorite button this selection should be saved to a persistent store that is saved between launches. If a favorited selection is ‘unfavorited’, this should be dealt with additionally.
* Favorited cryptocurrencies should always be displayed at the top of the table.
* The detail page has back/forward buttons with no constraints. Add constraints to make these buttons align with the coin title text.
* Back/forward buttons should be implemented to navigate between cryptocurrencies, following the same ordering from what is displayed on the main TableView.
* App should function properly on iPad and iPhone

Feel free to do whatever is needed to this code (including starting from scratch); nothing is off-limits. Some of the existing code _will_ be problematic &/or follow bad conventions, if you notice any of this, please refactor or fix as necessary. All code should follow Swift conventions, and if existing code does not meet this bar, it should be adjusted.

### Documentation 
Changes should be documented. A writeup about what was done, and why it was implemented in a specific way, will be helpful in understanding any decisions that were made. Please include information about any code you changed (and why) and any observations you have made about the existing code. If there are any changes to the project setup/compiling process, please include necessary steps (e.g. using a dependency manager, adding layout frameworks).

### Time 
Please time box work to no more than _4 hours_ of work. 

If you have additional time, please feel free improve maintainability, perform larger refactors, or implement any of the additional features below:

* animations (e.g. button clicks, custom segues, moving between detail VCs)
* dynamic app themes
* caching
* infinite scrolling
* sorting of any kind
* custom coin queries (see API for additional arguments)
* biometric app protection (requiring finger/face)

If time is running short, please spend more time documenting _how_ you would implement the above requirements, or what roadblocks were faced.

### Helpful Notes

* Remember, this is now _your_ project, please own this, make _any_ changes you want, and make it something that you are happy to send back to us.
* The initial CoreData stack has been implemented, interfacing methods are included in the AppDelegate.
* Git can be a useful method of documenting, you will notice Git has already been setup for this project.
* CrytpoCurrency information comes from the [CoinMarketCap API](https://coinmarketcap.com/api/).
