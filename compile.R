options(digits=4)

na0 <- function(x) { ifelse(is.na(x), 0, x) }

read <- function(file, ...) {
    read.csv(file, comment.char='#', strip.white=TRUE, ...)
}

write <- function(df, file, ...) {
    write.csv(df, file, na='0', quote=FALSE, row.names=FALSE, ...)
}

join <- function(files) {
    df <- do.call(rbind, lapply(files, function(x) { cbind(season=dirname(x), read(x)) }))
    df[order(as.character(df$batter), as.character(df$season)),]
}

averages <- function(stats) {
    # recalculate averages
    stats$BA  <- with(stats, round(na0(H / AB), 3))
    stats$OBP <- with(stats, round(na0((H + BB)/(AB + BB + SF)), 3))
    stats$SLG <- with(stats, round(na0((H + X2B + X3B*2 + HR*3)/AB), 3))
    stats$OPS <- with(stats, round(na0(OBP + SLG), 3))
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
    }
    if (sum(names(result) == 'games') == 2) {
        names(result)[match('games', names(result))] <- 'seasons'
    }
    result
}

reorder <- function(stats, columns) {
    stats[do.call(order, stats[columns]),]
}
