# Alpha Return

Compare your investments against market indices such as the S&P500 or even cryptos like Bitcoin to see if you are getting [Alpha](https://www.investopedia.com/terms/a/alpha.asp) returns. The returns from the benchmark and investments are in the form of [Annual Return](https://www.investopedia.com/terms/a/annual-return.asp) which is computed from the price on the buy and sell dates of said investments.

# Cross Platform App Development

Here is the current proof of concept for mobile and web being done with Flutter and Dart in Android Studio.

![alt_text](https://github.com/andrew-d-gordon/alpha-return/blob/master/docs/images/nexus_demo_beta.png?raw=true)

![alt_text](https://github.com/andrew-d-gordon/alpha-return/blob/master/docs/images/nexus_demo_beta_add_investment.png?raw=true)

![alt_text](https://github.com/andrew-d-gordon/alpha-return/blob/master/docs/images/nexus_demo_beta_add_investment_2.png?raw=true)

# Python Proof of Concept

An example run of the program, utilizing src/Input_Investments/investments1.csv, utilizing the S&P500 as a benchmark looks like this.

**investments1.csv**:

`Symbol,BuyDate,SellDate,Volume`

`AMZN,01/04/2021,11/12/2021,1`

`AAPL,01/04/2021,11/12/2021,1`

`BTC-USD,01/04/2021,11/12/2021,1`

`VTI,01/04/2021,11/12/2021,1`

With `market_index` set to `"sp500"` in alpha_return.py's main function as well as `test_file` set to `"investments1"`.

Output for return on individual investments against the benchmark market index/investment is sent to src/Input_Investments/test_returns.

The above AAPL row from investments1 against the sp500 results in **src/Input_Investments/test_returns/investments1_AAPL_sp500_returns**:

`Checking Alpha Return for AAPL investment against sp500.`

`=====================================`

`Buy and Sell dates: 01/04/2021, 11/12/2021`

`Investment Buy and Sell prices: (129.0, 149.99)`

`Investment Annual Return: 17.6529`

`Benchmark Buy and Sell prices: (3700.65, 4682.85)`

`Benchmark Annual Return: 27.5679`

`No Alpha Return: -9.915`

Similarly, the Bitcoin row from investments1 against the S&P500 results in **src/Input_Investments/test_returns/investments1_BTC-USD_sp500_returns**:

`Checking Alpha Return for BTC-USD investment against sp500.`

`=====================================`

`Buy and Sell dates: 01/04/2021, 11/12/2021`

`Investment Buy and Sell prices: (33992.43, 64469.53)`

`Investment Annual Return: 75.0064`

`Benchmark Buy and Sell prices: (3700.65, 4682.85)`

`Benchmark Annual Return: 27.5679`

`Alpha Return: 47.4385`
