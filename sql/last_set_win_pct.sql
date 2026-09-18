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

--Find how many 3 or 5 set matches each player has won and lost
--Add them to get the total amount of decisive sets played
fifth_set_winner as
(select 
    winner_name, 
    count(*) as fifth_set_win
from complete_table
where tourney_level='G' and score like '%-% %-% %-% %-% %-%'
group by winner_name),

fifth_set_loser as
(select 
    loser_name, 
    count(*) fifth_set_loss
from complete_table
where tourney_level='G' and score like '%-% %-% %-% %-% %-%'
group by loser_name),

third_set_winner as
(select 
    winner_name, 
    count(*) as third_set_win
from complete_table
where tourney_level in (250, 500, 'A', 'D', 'F', 'M') and score like '%-% %-% %-%'
group by winner_name),

third_set_loser as
(select 
    loser_name, 
    count(*) as third_set_loss
from complete_table
where tourney_level in (250, 500, 'A', 'D', 'F', 'M') and score like '%-% %-% %-%'
group by loser_name),

--Get a list of all names
all_names as
(select winner_name as name from fifth_set_winner
union
select loser_name as name from fifth_set_loser
union
select winner_name as name from third_set_winner
union
select loser_name as name from third_set_loser),

--Combine all the decisive sets wins and losses into one table
combined_stats as
(Select 
    all_names.name as name, 
    coalesce(fifth_set_win,0) as fifth_set_win,
    coalesce(third_set_win,0) as third_set_win,
    coalesce(fifth_set_loss,0) as fifth_set_loss,
    coalesce(third_set_loss,0) as third_set_loss
from all_names
left join fifth_set_winner on all_names.name = fifth_set_winner.winner_name
left join fifth_set_loser on all_names.name = fifth_set_loser.loser_name
left join third_set_winner on all_names.name = third_set_winner.winner_name
left join third_set_loser on all_names.name = third_set_loser.loser_name)

--Find last set win percentage
select
    name,
    fifth_set_win+third_set_win as last_set_wins,
    fifth_set_win+third_set_win+third_set_loss+fifth_set_loss as total_final_set,
    round((fifth_set_win+third_set_win)*1.0/(fifth_set_win+third_set_win+third_set_loss+fifth_set_loss),2) 
    as last_set_win_pct
from combined_stats
--Chosen to balance sample reliability against including enough players
where total_final_Set>10
order by last_set_win_pct desc
