--Combine years 2020-2025
with complete_table as
(Select 
    *
from '2020'
union all
Select 
    *
from '2021'
union all
Select 
    *
from '2022'
union all
Select 
    *
from '2023'
union all
Select 
    *
from '2024'
union all
Select 
    *
from '2025'),

--Find total wins, losses, and games 
total_wins AS
(select 
    winner_name,
    count(*) as wins
from complete_table
group by winner_name),

total_losses AS
(select 
    loser_name,
    count(*) as losses
from complete_table
group by loser_name),

total_games as
(select 
    coalesce(total_wins.winner_name, total_losses.loser_name) as name,
    coalesce(wins, 0) as wins,
    coalesce(wins, 0) + coalesce(losses, 0) as total_played
from total_wins
full outer join total_losses
on total_wins.winner_name=total_losses.loser_name 
order by name)

--Find the win percentage per player
select 
    name,
    total_played,
    round(wins*1.0/total_played,2) as win_pct
from total_games
--Chosen to balance sample reliability against including enough players
where total_played>=15
order by win_pct desc
