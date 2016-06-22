options(digits=4)

CATEGORIES <- c('seasons', 'games', 'batters', 'inn', 'PA', 'AB', 'R', 'H', 'X2B', 'X3B', 'HR', 'RBI', 'BB', 'SO', 'SF', 'GDP')
columns <- function(stats) { stats[which(names(stats) %in% CATEGORIES)] }

na0 <- function(x) { ifelse(is.na(x) | is.infinite(x), 0.0, x) }

read <- function(file, ...) {
    read.csv(file, comment.char='#', fill=TRUE, strip.white=TRUE, ...)
}

write <- function(df, file, ...) {
    # write.csv(df, file, na='0', quote=FALSE, row.names=FALSE, ...)
    write.fwf(df, file, na='0', sep=', ')
}

join <- function(files, columns) {
    df <- do.call(rbind, lapply(files, function(x) { cbind(season=dirname(x), read(x)) }))
    df[do.call(order, lapply(df[columns], function(x) if (is.factor(x)) as.character(x) else x)),]
}

averages <- function(stats) {
    # recalculate averages
    tb <- with(stats, (H + X2B + X3B*2 + HR*3))
    stats$BA  <- with(stats, round(na0(H / AB), 3))
    stats$OBP <- with(stats, na0((H + BB) / PA))
    stats$SLG <- with(stats, na0(tb / AB))
    stats$OPS <- with(stats, round(OBP + SLG, 3))
    stats$SA  <- with(stats, round(na0((tb - H + BB) / AB), 3))
    stats$RC  <- with(stats, round(na0(((2.4*PA + H + BB - GDP) * (3*PA + 1.125*H + 0.565*X2B + 1.895*X3B + 2.605*HR + 0.29*BB + 0.492*SF - 0.04*SO) / (9*PA)) - 0.9*PA), 3))
    stats$XR  <- with(stats, round(0.5*H + 0.22*X2B + 0.54*X3B + 0.94*HR + 0.34*BB + 0.37*SF - 0.098*SO - 0.09*(AB-H-SO) - 0.37 * GDP, 3))
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

write.fwf <- function (x, file = "", append = FALSE, quote = FALSE, sep = " ", na = "", row.names = FALSE, col.names = TRUE, rowCol = NULL, justify = "right", quoteInfo = TRUE, width = NULL, eol = "\n", qmethod = c("escape", "double"), ...) {
    # modified version of write.fwf (from gdata package) to make column names
    # and data space-aligned
    if (!(is.data.frame(x) || is.matrix(x))) stop("'x' must be a data.frame or matrix")
    if (length(na) > 1) stop("only single value can be defined for 'na'")
    localWrite.table <- function(...) { write.table(file = file, quote = quote, sep = sep, eol = eol, na = na, row.names = FALSE, col.names = FALSE, qmethod = qmethod, ...) }
    if (row.names) {
        x <- cbind(row.names(x), x)
        rowColVal <- ifelse(!is.null(rowCol), rowCol, "row")
        colnames(x)[1] <- rowColVal
    }
    colnamesMy <- colnames(x)
    nRow <- nrow(x)
    nCol <- length(colnamesMy)
    widthNULL <- is.null(width)
    if (!widthNULL && length(width) != nCol) {
        warning("recycling 'width'")
        widthOld <- width
        width <- integer(length = nCol)
        width[] <- widthOld
    }
    retFormat <- data.frame(colname = colnamesMy, nlevels = 0, position = 0, width = 0, digits = 0, exp = 0, stringsAsFactors = FALSE)
    isNum <- sapply(x, is.numeric)
    isNum <- isNum & !(sapply(x, inherits, what = "Date") | sapply(x, inherits, what = "POSIXt"))
    isFac <- sapply(x, is.factor)
    x[, isFac] <- lapply(x[, isFac, drop = FALSE], as.character)
    tmp <- lapply(x, format.info, ...)
    tmp1 <- sapply(tmp, length)
    tmp <- t(as.data.frame(tmp))
    retFormat$width <- tmp[, 1]
    if (any(isNum)) {
        test <- tmp1 > 1
        if (any(test)) {
            retFormat[test, c("digits", "exp")] <- tmp[test, c(2, 3)]
            test2 <- tmp[test, 3] > 0
            if (any(test2)) retFormat[test, ][test2, "exp"] <- retFormat[test, ][test2, "exp"] + 1
        }
    }
    for (i in 1:nCol) {
        if (widthNULL) {
            tmp <- nchar(colnamesMy[i])
        }
        else {
            tmp <- width[i]
        }
        test <- is.na(x[, i])
        x2 <- character(length = nRow)
        x2[!test] <- format(x[!test, i], nsmall = 3, justify = justify, width = tmp, ...)
        x2[test] <- na
        x[, i] <- x2
        tmp2 <- format.info(x[, i], ...)[1]
        if (tmp2 != retFormat[i, "width"]) {
            retFormat[i, "width"] <- tmp2
            x[, i] <- format(x[, i], nsmall = 3, justify = ifelse(isNum[i], "right", justify), width = tmp, ...)
        }
        if (nchar(na) < retFormat[i, "width"]) {
            x[test, i] <- format(na, nsmall = 3, justify = ifelse(isNum[i], "right", justify), width = retFormat[i, "width"], ...)
        }
    }
    if (any(!isNum)) {
        retFormat[!isNum, "nlevels"] <- sapply(x[, !isNum, drop = FALSE], function(z) length(unique(z)))
    }
    if (!widthNULL) {
        retFormat$width <- pmax.int(retFormat$width, width)
    }
    if (col.names) {
        if (row.names && is.null(rowCol)) colnamesMy <- colnamesMy[-1]
        localWrite.table(t(as.matrix(mapply(format, colnamesMy, justify = justify, width = retFormat$width))), append = append)
    }
    localWrite.table(x = x, append = (col.names || append))
}
