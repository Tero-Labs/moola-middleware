from celo_sdk.kit import Kit
import json
import datetime
from pycoingecko import CoinGeckoAPI
from fastapi import FastAPI,Depends, Query # Query = for length checking

from fastapi.middleware.cors import CORSMiddleware

from enum import Enum
from typing import Optional

app = FastAPI( title="Moola Rate and Fee Service API",
    description="To Serve MobileApps & Dashboards",
    version="0.1.0",)

# --------- CORS -----------
origins = [
     "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
#-------- End of CORS ---------

class ActivityPermittedList(str, Enum):
	deposit = "deposit"
	withdraw = "withdraw"
	borrow = "borrow"
	repay = "repay"
	liquidate = "liquidate"

class CurrencyPermittedList(str, Enum):
	cusd = "cusd"
	celo = "celo"
	ceuro = "ceuro"

address_regex = '/[a-fA-F0-9]{40}$/'

Default_Currency = 'celo'

with open("./abis/LendingPool.json") as f:
    Lending_Pool = json.load(f)

with open("./abis/IPriceOracleGetter.json") as f:
    IPrice_Oracle_Getter = json.load(f)  


'''
  Start of Fee service
'''
cg = CoinGeckoAPI()

ether = 1000000000000000000

kit = Kit('https://forno.celo.org')
gas_contract = kit.base_wrapper.create_and_get_contract_by_name('GasPriceMinimum')

web3 = kit.w3
eth = web3.eth

lendingPool = eth.contract(address= '0x0886f74eEEc443fBb6907fB5528B57C28E813129', abi= Lending_Pool) 

gas_contract = kit.base_wrapper.create_and_get_contract_by_name('GasPriceMinimum')

coin_reserve_address = {
        "celo": "0x471EcE3750Da237f93B8E339c536989b8978a438",
        "cusd": "0x765DE816845861e75A25fCA122bb6898B8B1282a",
        "ceuro":"0xD8763CBa276a3738E6DE85b4b3bF5FDed6D6cA73"
}

def get_gas_price(coin_name):    
    return gas_contract.get_gas_price_minimum(coin_reserve_address[coin_name.lower()])

def estimate_gas_amount(activity, amount, coin_name, user_address):
    if activity == 'deposit':
        return lendingPool.functions.deposit(coin_reserve_address[coin_name.lower()], amount, 0).estimateGas({
            'from': web3.toChecksumAddress(user_address), 
        })
    elif activity == 'borrow':
        return lendingPool.functions.borrow(coin_reserve_address[coin_name.lower()], amount, 1, 0).estimateGas({
            'from': web3.toChecksumAddress(user_address), 
        })
    elif activity == 'repay':
        return lendingPool.functions.repay(coin_reserve_address[coin_name.lower()], amount, web3.toChecksumAddress('0x011ce5bd73a744b2b5d12265be37250defb5b590')).estimateGas({
            'from': web3.toChecksumAddress(user_address), 
        })
    elif activity == 'withdraw':
        return lendingPool.functions.redeemUnderlying(coin_reserve_address[coin_name.lower()], web3.toChecksumAddress('0x011ce5bd73a744b2b5d12265be37250defb5b590'), amount, 0).estimateGas({
            'from': web3.toChecksumAddress(user_address), 
        })
    
def wei_to_celo(price_in_wei):
    return ((price_in_wei/ether)*cg.get_price(ids='ethereum', vs_currencies='usd')['ethereum']['usd'])/cg.get_price(ids='celo', vs_currencies='usd')['celo']['usd']


### get the fees in celo
def get_fee(activity, amount, coin_name, user_address):
    return estimate_gas_amount(activity, amount, coin_name, user_address) * (wei_to_celo(get_gas_price(coin_name)))

### test get_fee
# print(get_fee("deposit", 150, 'celo', "0x011ce5bd73a744b2b5d12265be37250defb5b590"))
# print(get_fee("deposit", 150, 'cusd', "0x011ce5bd73a744b2b5d12265be37250defb5b590"))
# print(get_fee("deposit", 150, 'ceuro', "0x011ce5bd73a744b2b5d12265be37250defb5b590"))
# print(get_fee("borrow", 150, 'celo', "0x011ce5bd73a744b2b5d12265be37250defb5b590"))
# print(get_fee("repay", 150, 'celo', "0x011ce5bd73a744b2b5d12265be37250defb5b590"))
# print(get_fee("withdraw", 150, 'celo', "0x011ce5bd73a744b2b5d12265be37250defb5b590"))

# /get/getFee
#http://127.0.0.1:8000/get/getFee?userPublicKey=011ce5bd73a744b2b5d12265be37250defb5b590&activityType=borrow&amount=40.0
@app.get("/get/getFee")
async def get_getFee(userPublicKey: str = Query(address_regex),activityType: ActivityPermittedList = None, amount: int = None,currency: Optional[CurrencyPermittedList] = Default_Currency):

	executionDateTime = datetime.datetime.now(datetime.timezone.utc).timestamp()

	TotalFee = get_fee(activityType, amount, currency, "0x" + userPublicKey)

	return {'status':'OK',
			'dateTime':executionDateTime,
			'userPublicKey':userPublicKey,
			'currency': currency,
			'activity': activityType,
			'amount': amount,
			'fee': TotalFee
			}

'''
  End of Fee service
'''

'''
  Start of Rate service
'''
coins_reserve_address = {
         "celo": '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE',
         "cusd": '0x765DE816845861e75A25fCA122bb6898B8B1282a' , 
         "ceuro": '0xD8763CBa276a3738E6DE85b4b3bF5FDed6D6cA73'  
}

price_oracle = eth.contract(address='0x568547688121AA69bDEB8aEB662C321c5D7B98D0', abi= IPrice_Oracle_Getter)

def get_exchange_rate_in_usd(coin_name, coin_address):
    price_in_celo = (price_oracle.functions.getAssetPrice(coin_address).call()/ether)
    return price_in_celo*cg.get_price(ids='celo', vs_currencies='usd')['celo']['usd']

#test getRateInUsd
# print(get_exchange_rate_in_usd("celo", coins_reserve_address["celo"]))

# /get/getRateInUsd
#http://127.0.0.1:8000/get/getRateInUsd?coin_name=celo
@app.get("/get/getRateInUsd")
async def get_getFee(coin_name: CurrencyPermittedList):

	executionDateTime = datetime.datetime.now(datetime.timezone.utc).timestamp()

	exchange_rate_in_usd = get_exchange_rate_in_usd(coin_name, coins_reserve_address[coin_name] )

	return {'status':'OK',
			'dateTime':executionDateTime,
			'coinName': coin_name,
			'RateInUsd': exchange_rate_in_usd,
			}

'''
  End of Rate service
'''
