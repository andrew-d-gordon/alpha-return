from datetime import datetime
from concurrent import futures

import pandas as pd
from pandas import DataFrame
import pandas_datareader.data as web


def download_stock(stock:str, buy_date, sell_date):
    """
    arg stock: ticker symbol of stock to retrieve price for
    return: returns value of stock 
    """

    if sell_date <= buy_date: # If sell date is prior to or the same as the buy date
        print('bad: %s and %s, buy time greater than or equal to now_time' % (buy_date, sell_date))
        return

    try:
        stock_buy_info = web.get_data_yahoo(symbols=stock, start=buy_date, end=buy_date)
        stock_sell_info = web.get_data_yahoo(symbols=stock, start=sell_date, end=sell_date)
        stock_buy_price = float(stock_buy_info['Adj Close'].tail(1)[0])
        stock_sell_price = float(stock_sell_info['Adj Close'].tail(1)[0])
        #print("Stock buy price for %s on %s:" % (stock, str(buy_date)), stock_buy_price)
        #print("Stock sell price for %s on %s:" % (stock, str(sell_date)), stock_sell_price)
    except:
        #bad_names.append(stock)
        print('Could not acquire information for: %s' % (stock))
        return 0
    
    return stock_buy_price, stock_sell_price


def parse_sp500_historical_csv(file_name:str, columns:tuple, four_digit_years:bool=True):
    """
    Note: Columns in csv must not be separated by spaces to be parsed by pandas

    arg file_name: str relating to csv file to parse
    arg column_index: int relating to the desired columns
    arg four_digit_years: if 'yyyy' desired for year column in dict, append '20' or '19' respectively.
    return: generates dictionary with day as key and closing price as value
    """

    # Read desired csv file with date and closing price columns
    df = pd.read_csv(file_name, usecols=columns)
    date_column = columns[0]
    price_column = columns[1]
    
    # Convert data frame into dictionary for O(1) lookups by date later
    sp500_closing_dict = {}
    for i in range(df.shape[0]):

        # Pull off date for key
        date = df[date_column][i]

        # If years desired as 'yyyy' instead of 'yy', make conversion
        if four_digit_years: 
            date_split = str(date).split('/')
            if 59 < int(date_split[-1]) <= 99: # If Pre 2000s, append '19'
                date_split[-1] = '19' + date_split[-1]
            else: # If Post 2000s, append '20', will need revisiting by 2099...
                date_split[-1] = '20' + date_split[-1]
            date = '/'.join(date_split)

        sp500_closing_dict[date] = df[price_column][i]

    return sp500_closing_dict


def find_annual_return(buy_price:float, sell_price:float, days_diff:int, days_in_year=365.25):
    """
    arg buy_price: buy price for investment
    arg sell_price: sell price for investment
    arg days_diff: difference in days between buy and sell date
    return: annual return for investment as percentage float
    """

    # Set up compound interest 'magic', daily compound interest
    x_temp = pow((sell_price/buy_price), 1/days_diff)

    # Compute annual return
    annual_return = round((x_temp-1)*(days_in_year*1000000))
    annual_return /= 10000

    return annual_return


def compute_alpha_return(benchmark: tuple, inv: tuple, buy_date: tuple, sell_date: tuple):
    """
    arg benchmark: tuple containing buy and sell date closing prices for benchmark market (sp500 only at the moment)
    arg investment_difference: tuple containing difference between buy and sell date closing prices for investment
    return: compound interest return and total difference return on investment
    """
    
    # Find Days Differential
    days_different = datetime(sell_date[0], sell_date[1], sell_date[2]) - datetime(buy_date[0], buy_date[1], buy_date[2])
    days_different = days_different.days

    # Find Annual Return for inv
    annual_return_inv = find_annual_return(inv[0], inv[1], days_different)

    # Find Annual Return for benchmark
    annual_return_benchmark = find_annual_return(benchmark[0], benchmark[1], days_different)

    print("Investment annual return:", annual_return_inv)
    print("Benchmark annual return:", annual_return_benchmark)

    # Return return differential between investment and benchmark
    return annual_return_inv - annual_return_benchmark


def parse_investment_input(file_name:str, columns:list=['Symbol','BuyDate','SellDate','Volume']):
    """
    Input files must follow format described in docs/Input_Investments.md.
    Example Return: {'AMZN':{'BuyDate':'01/04/2021','SellDate':'01/04/2021','Volume':1}}

    arg file_name: investment input file name
    return: a dictionary where keys are tickers and values are dictionary with investment data
    """

    df = pd.read_csv(file_name, usecols=columns)
    investment_dict = {}
    for i in range(df.shape[0]):
        # Initialize value dict to hold investment data
        investment_dict[i] = {} 

        # Loop through columns, fill out value dict
        for c in columns: 
            investment_dict[i][c] = df[c][i]

    return investment_dict


if __name__ == '__main__':

    # Retrieve S&P500 data closing prices
    columns = ["Date", "Close"]
    sp500_csv_file = 'src/SP500_CSV/HistoricalPrices.csv'
    sp500_dict = parse_sp500_historical_csv(sp500_csv_file, columns)

    # Retrieve Investment Data
    investment_input_file = 'src/Input_Investments/investments1.csv'
    investments = parse_investment_input(investment_input_file)
    for i in investments:
        print(i, investments[i])

    # Set investment data
    now_time = datetime.now()
    start_time = datetime(now_time.year - 5, now_time.month, now_time.day)
    for i in investments:

        # Grab investment dict from investments
        investment = investments[i]
        print("\nChecking Alpha Return for %s.\n===============================" % investment['Symbol'])

        # Format respective dates for buying and selling, int tuple: (yyyy, mm, dd)
        buy_date_split = investment['BuyDate'].split('/')
        bd_int = [int(x) for x in buy_date_split]
        buy_date = (bd_int[2], bd_int[0], bd_int[1])

        sell_date_split = investment['SellDate'].split('/')
        sd_int = [int(x) for x in sell_date_split]
        sell_date = (sd_int[2], sd_int[0], sd_int[1])

        # Find investment prices on buy and sell date
        inv_prices = download_stock(investment['Symbol'], 
                                    datetime(bd_int[2], bd_int[0], bd_int[1]),
                                    datetime(sd_int[2], sd_int[0], sd_int[1]))
        if not inv_prices: # If prices for this investment could not be acquired, skip
            continue
        print("This is Investment buy and sell prices", inv_prices)
        
        # Find benchmark market (sp500) and investment prices on buy and sell date
        benchmark_prices = (sp500_dict[investment['BuyDate']], sp500_dict[investment['SellDate']])
        print("This is Benchmark buy and sell prices:", benchmark_prices)

        # Find return differential
        return_differential = compute_alpha_return(benchmark_prices, inv_prices, buy_date, sell_date)

        if return_differential > 0: # Print results
            print("Alpha Return:", return_differential)
        else:
            print("No Alpha Return:", return_differential)

    

#https://www.kite.com/python/answers/how-to-read-specific-column-from-csv-file-in-python#:~:text=To%20read%20a%20CSV%20file,the%20column%20name%20to%20read.