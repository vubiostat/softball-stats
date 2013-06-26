options(digits=4)

CATEGORIES <- c('seasons', 'games', 'batters', 'inn', 'PA', 'AB', 'R', 'H', 'X2B', 'X3B', 'HR', 'RBI', 'BB', 'SO', 'SF', 'GDP')
columns <- function(stats) { stats[which(names(stats) %in% CATEGORIES)] }

na0 <- function(x) { ifelse(is.na(x), 0, x) }

read <- function(file, ...) {
    read.csv(file, comment.char='#', fill=TRUE, strip.white=TRUE, ...)
}

write <- function(df, file, ...) {
    write.csv(df, file, na='0', quote=FALSE, row.names=FALSE, ...)
}

join <- function(files, columns) {
    df <- do.call(rbind, lapply(files, function(x) { cbind(season=dirname(x), read(x)) }))
    df[do.call(order, lapply(df[columns], function(x) if (is.factor(x)) as.character(x) else x)),]
}

averages <- function(stats) {
    # recalculate averages
    tb <- with(stats, (H + X2B + X3B*2 + HR*3))
    stats$BA  <- with(stats, round(na0(H / AB), 3))
    stats$OBP <- with(stats, na0((H + BB) / (AB + BB + SF)))
    stats$SLG <- with(stats, na0(tb / AB))
    stats$OPS <- with(stats, round(OBP + SLG, 3))
    # stats$SA  <- with(stats, round((tb - H + BB) / AB, 3))
    # stats$RC  <- with(stats, round(((2.4*PA + H + BB - GDP) * (3*PA + 1.125*H + 0.565*X2B + 1.895*X3B + 2.605*HR + 0.29*BB + 0.492*SF - 0.04*SO) / (9*PA)) - 0.9*PA, 3))
    # stats$XR  <- with(stats, round(0.5*H + 0.22*X2B + 0.54*X3B + 0.94*HR + 0.34*BB + 0.37*SF - 0.01*SO - 0.09*(AB-H-SO), 3))
    stats$OBP <- round(stats$OBP, 3)
    stats$SLG <- round(stats$SLG, 3)
    stats
}

compile <- function(stats, by) {
    # tally
    result <- averages(aggregate(stats, by=by, FUN=sum))
    # sub-set sizes
    result <- cbind(result[1:length(by)], games=structure(unclass(table(by)), dimnames=NULL), result[-c(1:length(by))])
    # rename sub-set category as appropriate
    if ('game' %in% names(by)) {
        names(result)[match('games', names(result))] <- 'batters'
        inn <- aggregate(stats['inn'], by=by, FUN=max)
        result$inn[match(result$game, inn$game)] <- inn$inn
    }
    if (sum(names(result) == 'games') == 2) {
        names(result)[match('games', names(result))] <- 'seasons'
    }
    result
}

reorder <- function(stats, columns) {
    stats[do.call(order, stats[columns]),]
}
