#Moola Middleware Codebase

This repository contains codebase used for upstream & downstream middleware agent server. It also contains the SQL files and codes used for synthetic data generation

## Directory Structure

The following is a high level overview of relevant files and folders:

```
moola-middleware/
├── api/
│   ├── downstream/     
│   │    ├── main.py
│   │    ├── Procfile
│   │    └── requirements.txt
│   └── upstream/     
│        ├── main.py
│        ├── Procfile
│        └── requirements.txt
├── celo_sdk/
├── service/
│   ├── coin_exchange/   
│   │    ├── abis/  
│   │    ├── main.py
│   │    ├── setup.py
│   │    ├── Procfile
│   │    ├── runtime.txt
│   │    └── requirements.txt
│   └── rate_fee/     
│        ├── abis/  
│        ├── main.py
│        ├── setup.py
│        ├── Procfile
│        ├── runtime.txt
│        └── requirements.txt
└── README.md
```

## Database

* Checkout to the branch [db](https://github.com/Tero-Labs/moola-middleware/tree/db) to find the SQL files used in the codebase
* Checkout to the branch [data](https://github.com/Tero-Labs/moola-middleware/tree/data) to find the codebase used for synthetic data generation which populates  PostgreSQL DB table with random ranged value for test, validation and development