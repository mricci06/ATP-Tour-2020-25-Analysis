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

--Find total aces in wins, losses, and add them to get total
wins_aces AS
(select 
    winner_name,
    surface,
    count(*) as wins, 
    sum(w_ace) as w_aces,
    sum(w_svpt) as w_svpt
from complete_table
where w_svpt is not null
group by winner_name, surface),

losses_aces AS
(select 
    loser_name,
    surface,
    count(*) as losses,
    sum(l_ace) as l_aces,
    sum(l_svpt) as l_svpt
from complete_table
where l_svpt is not null
group by loser_name, surface),

total_aces as
(select 
    coalesce(wins_aces.winner_name, losses_aces.loser_name) as name,
    coalesce(wins_aces.surface, losses_aces.surface) as surface,
    coalesce(wins, 0) as wins,
    coalesce(losses, 0) as losses,
    coalesce(w_aces, 0) + coalesce(l_aces, 0) as total_aces,
    coalesce(w_svpt, 0) + coalesce(l_svpt, 0) as total_svpt
from wins_aces
full outer join losses_aces 
on wins_aces.winner_name=losses_aces.loser_name AND
wins_aces.surface=losses_aces.surface)

--Find aces per match, and ace percentage
select 
    name, 
    surface,
    wins+losses as total_matches,
    round(total_aces/(wins+losses),2) as aces_per_match,
    round(total_aces/total_svpt,3) as ace_pct
from total_aces
--Chosen to balance sample reliability against including enough players
where total_matches>=5
order by aces_per_match DESC