# delayTTC
This repository is a copy of the CSC343 University of Toronto research project Jon Gabriel and myself (Nikolas Till) had designed and developed. Using a PostgreSQL database and public TTC delay data we sought to compare features of TTC delays and learn how this affected their ridership revenue.

## Research Proposal

A full outline of our research topic and [PostgreSQL schema](./schema.ddl) for this project is defined in the [Research Proposal paper](./Research_Proposal_Paper.pdf).

The [questions](./Research_Results.pdf) we sought to answer for this project were the following:

1. Which months of the year have the most delays and how does this impact TTC ridership and
revenue?

2. What types of delays cause the longest delay? What are the most frequent types of delays?
Which stations have the most of these types of delays?

3. Which streetcar, buses, and trains (by vehicle number) have the most delays due to
mechanical issues? What type of vehicle is the most susceptible to delays (the average least
amount of days between mechanical delays for the same vehicle)? Which buses by route are
the worst relative to delays?

## Method
After formatting public ttc delay data, we copied it into a [PostgreSQL database](./schema.ddl) we designed and performed [queries](./queries.sql) on it for our research.

## Results
The results of our research are outlined in the [Research Results paper](./Research_Results.pdf) along with a [sample output](./queries-demo.txt) of the queries that were performed to develop the results of our research project. 


## Credits
- TTC delay data was retrieved from https://open.toronto.ca/
