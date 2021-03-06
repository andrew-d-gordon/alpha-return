from datetime import datetime
from concurrent import futures
from os import error

import pandas as pd
from pandas import DataFrame
import pandas_datareader.data as web


def retrieve_market_value(ticker:str, buy_date, sell_date):
    """
    Serves to retrieve the market value for a given investment/index for a buy and sell date.

    arg ticker: ticker symbol of investment/index to retrieve price for
    arg buy_date: datetime date corresponding to start date for desired query
    arg sell_date: datetime date corresponding to end date for desired query
    return: returns value of stock 
    """

    if sell_date <= buy_date: # If sell date is prior to or the same as the buy date
        print('bad: %s and %s, buy time greater than or equal to now_time' % (buy_date, sell_date))
        return

    try:
        inv_buy_info = web.get_data_yahoo(symbols=ticker, start=buy_date, end=buy_date)
        inv_sell_info = web.get_data_yahoo(symbols=ticker, start=sell_date, end=sell_date)
        inv_buy_price = float(inv_buy_info['Adj Close'].tail(1)[0])
        inv_sell_price = float(inv_sell_info['Adj Close'].tail(1)[0])
    except error:
        #bad_names.append(stock)
        print(error)
        print('Could not acquire information for: %s' % (ticker))
        return 0
    
    return round(inv_buy_price, 2), round(inv_sell_price, 2)


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
    return: rounded difference in annual returns as well as annual return for investment and benchmark
    """
    
    # Find Days Differential
    days_different = datetime(sell_date[0], sell_date[1], sell_date[2]) - datetime(buy_date[0], buy_date[1], buy_date[2])
    days_different = days_different.days

    # Find Annual Return for inv
    annual_return_inv = find_annual_return(inv[0], inv[1], days_different)

    # Find Annual Return for benchmark
    annual_return_benchmark = find_annual_return(benchmark[0], benchmark[1], days_different)

    # Return return differential between investment and benchmark
    return round(annual_return_inv - annual_return_benchmark, 4), annual_return_inv, annual_return_benchmark


def analyze_investments(investment:dict, benchmark:str='^GSPC', log_output=True):
    """
    Takes dictionary of an investment, compares it against the benchmark market (default sp500).
    The comparison made is based on annual return, alpha return is denoted by an annual return greater than the benchmarks.

    arg investment: dictionary containing an investment and it's purchase dates + volume
    arg benchmark: benchmark market symbol to compare investments against
    arg log_output: boolean to determine whether or not to log output to src/Input_Investments/test_returns
    return: none, displays relevant information to alpha return on investments
    """

    # Pull off investment data
    ticker = investment['Symbol']
    buy_date_raw = investment['BuyDate']
    sell_date_raw = investment['SellDate']

    # Format respective dates for buying and selling, int tuple: (yyyy, mm, dd)
    buy_date_split = buy_date_raw.split('/')
    bd_int = [int(x) for x in buy_date_split]
    buy_date = (bd_int[2], bd_int[0], bd_int[1])

    sell_date_split = sell_date_raw.split('/')
    sd_int = [int(x) for x in sell_date_split]
    sell_date = (sd_int[2], sd_int[0], sd_int[1])

    # Find investment prices on buy and sell date
    inv_prices = retrieve_market_value(ticker, 
                        datetime(bd_int[2], bd_int[0], bd_int[1]),
                        datetime(sd_int[2], sd_int[0], sd_int[1]))
    # If prices for this investment could not be acquired, skip
    if not inv_prices: 
        print("Information regarding investment could not be found for: %s" % (ticker))
        return -1
    
    # Find benchmark market index values on buy and sell date
    try: # If we have prices locally, utilize those
        benchmark_prices = (benchmark_dict[buy_date_raw], benchmark_dict[sell_date_raw])
    except KeyError: # If we do not have prices locally, retrieve them from Yahoo and save off.
        benchmark_prices = retrieve_market_value(benchmark,
                                datetime(bd_int[2], bd_int[0], bd_int[1]),
                                datetime(sd_int[2], sd_int[0], sd_int[1]))
        # Save fetch call to Yahoo to local dict
        benchmark_dict[buy_date_raw] = benchmark_prices[0]
        benchmark_dict[sell_date_raw] = benchmark_prices[1]
    
    # Find return differential
    return_differential, i_return, b_return = compute_alpha_return(benchmark_prices, inv_prices, buy_date, sell_date)

    if log_output: # If logging of output is desired, write to output file for test.
        output_file = open('src/Input_Investments/test_returns/'+test_file+'_'+ticker+'_'+market_index+'_returns', 'w')
        log_lines = [] # List holding lines to write to output file
        log_lines.append("Checking Alpha Return for %s investment against %s.\n=====================================\n"% (ticker,market_index))
        log_lines.append("Buy and Sell dates: {0}, {1}\n".format(buy_date_raw, sell_date_raw))
        log_lines.append("Investment Buy and Sell prices: {0}\n".format(inv_prices))
        log_lines.append("Investment Annual Return: {0}\n".format(i_return))
        log_lines.append("Benchmark Buy and Sell prices: {0}\n".format(benchmark_prices))
        log_lines.append("Benchmark Annual Return: {0}\n".format(b_return))

        if return_differential > 0: # Append Alpha Return results
            log_lines.append("Alpha Return: {0}\n".format(return_differential))
        else:
            log_lines.append("No Alpha Return: {0}\n".format(return_differential))

        # Write lines to file
        output_file.writelines(log_lines)
        
    return (investment, benchmark, return_differential)


def parse_market_index_historical_csv(file_name:str, columns:tuple, four_digit_years:bool=True):
    """
    Note: Columns in csv must not be separated by spaces to be parsed by pandas.

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
    
    # Set time tracking for computation
    start_time = datetime.now()

    # Initialize Benchmark Options
    benchmarks = {
        'sp500':{
            'ticker':'^GSPC',
            'csv':'src/Benchmark_CSVs/sp500.csv'},
        'dow':{
            'ticker':'^DJI',
            'csv':''},
        'nasdaq': {
            'ticker':'^IXIC',
            'csv':''},
        'bitcoin': {
            'ticker':'BTC-USD',
            'csv':''
        }
    }

    # Retrieve S&P500 data closing prices
    columns = ["Date", "Close"]
    market_index = 'bitcoin'
    benchmark_csv = benchmarks[market_index]['csv']
    benchmark_dict = parse_market_index_historical_csv(benchmark_csv, columns) if benchmark_csv != '' else {}

    # Retrieve Investment Data
    test_file = 'investments1'
    investment_input_file = 'src/Input_Investments/{0}.csv'.format(test_file)
    investments = parse_investment_input(investment_input_file)

    # for i in investments: print(i, investments[i]) # Print investments being processed
        
    # Find return on investments (threaded)
    max_workers = 50 # Set the maximum thread number
    workers = min(max_workers, len(investments.keys())) # In case a smaller number of stocks than threads was passed in
    with futures.ThreadPoolExecutor(workers) as executor:
        # Process investment data
        res = executor.map(analyze_investments, [investments[i] for i in investments], [benchmarks[market_index]['ticker'] for i in range(len(investments))]) 

    # Print results
    res = list(res)
    for r in res:
        print("=====================================")
        print("Alpha Annual Return for {0} against benchmark {1}: {2}.".format(r[0]['Symbol'], market_index, r[2]))
        print("Start Date: {0} and End Date: {1}\n".format(r[0]['BuyDate'], r[0]['SellDate']))

    # Find return on investments (non-threaded)
    '''
    for i in investments:
        analyze_investments(investments[i], benchmarks['sp500']) # Utilize if threading not desired
    '''
    
    # Print Time related information
    finish_time = datetime.now()
    duration = finish_time - start_time
    minutes, seconds = divmod(duration.seconds, 60)
    print('alpha_return.py')
    print(f'The script took {minutes} minutes and {seconds} seconds to run.')