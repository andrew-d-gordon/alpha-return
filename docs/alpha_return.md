# alpha_return.py

alpha_return.py contains the driver code for creating alpha return analysis between investments and the benchmark.

Within the main function we can view a threaded and non thread version of analysing investments.

Investments can be parsed through creating an investments.csv file in Input_Investments and setting investment_input_file to point at it. (Make sure to follow the necessary structure as outlined in docs/Input_Investments.md or as shown in src/Input_Investments/investments1.csv)

alpha_return.py relies on pandas datareader in order to query Yahoo finance for retrieving the closing price for an investment on a given day. In order to utilize various benchmarks, Yahoo finance can also be pinged to retrieve market index closing prices.

Once these closing prices have been received, the annual return is computed by utilizing the day differential between buy and sell (start and end dates). With the annual return, an 'Alpha' return can be computed by taking the differential of the investment return to the benchmark return.

By default, output of these operations is stored into src/Input_Investments/test_returns