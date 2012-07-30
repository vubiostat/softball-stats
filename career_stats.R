source('compile.R')

# combine player-game batting stats across seasons
batting <- join(system('ls */batting_stats.txt', TRUE), c('batter','season','game'))
write(batting, 'batting_stats.txt')

# combine player-season batting stats across seasons
batting_seasons <- join(system('ls */batting_stats_season.txt', TRUE), c('batter','season'))
write(batting_seasons, 'batting_stats_season.txt')

# compile player career batting stats
batting_career <- compile(columns(batting_seasons), batting_seasons['batter'])
batting_career <- batting_career[order(as.character(batting_career$batter)),]
write(batting_career, 'batting_stats_career.txt')

# combine team-game batting stats across seasons
team_batting <- join(system('ls */team_batting_stats.txt', TRUE), c('season','game'))
write(reorder(team_batting, c('season', 'game')), 'team_batting_stats.txt')

# combine team-season batting stats across seasons
team_batting_seasons <- join(system('ls */team_batting_stats_season.txt', TRUE), c('season'))
write(reorder(team_batting_seasons, 'season'), 'team_batting_stats_season.txt')
