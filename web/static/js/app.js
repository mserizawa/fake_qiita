angular.module("fakeQiitaApp", [])
    .controller("FakeQiitaController", ["$scope", "$http", function($scope, $http) {

        var qiitaDateFormat = "YYYY-MM-DD'T'HH:mm:ssZ",
            streakDateFormat = "MMMM D",
            displayYMDFormat = "MMM D, YYYY",
            entries = [],
            userId = $("#dto").data("user-id");

        $scope.searchWord = "";
        $scope.popularEntries = [];
        $scope.contributions = 0;
        $scope.contribStats = [
            { title: "Contributions in the last year", count: 0, unit: "total" },
            { title: "Longest streak", count: 0, unit: "days" },
            { title: "Current streak", count: 0, unit: "days" },
        ];
        $scope.filteredActivities = [];
        $scope.periodPresets = [
            { label: "1 day", from: moment().add(-1, "days") },
            { label: "3 days", from: moment().add(-3, "days") },
            { label: "1 week", from: moment().add(-1, "weeks") },
            { label: "1 month", from: moment().add(-1, "months") }
        ];
        $scope.periodLabel = "";
        $scope.isLoading = true;

        $scope.changePeriod = function(label, from, to) {
            if (!to) {
                to = moment();
            }
            var filtered = [];
            entries.forEach(function(entry) {
                if (entry.parsed_created_at.isAfter(from) &&
                    entry.parsed_created_at.isBefore(to)) {

                    filtered.push(entry);
                }
            });
            $scope.filteredActivities = filtered;
            $scope.periodLabel = label;
        }

        $scope.searchQiita = function() {
            if (!$scope.searchWord) {
                return;
            }
            location.href = "http://qiita.com/search?utf8=%E2%9C%93&sort=rel&q=" + $scope.searchWord;
        }

        $http.get("/" + userId + "/entries.json").success(function(dt) {
            $scope.isLoading = false;

            var calData = {},
                now = moment(),
                contributionsLastYear = 0,
                prevDate = null,
                tmpStreak = 0,
                tmpStreakEndDate = null,
                longestStreak = 0,
                longestStreakEndDate = null;

            dt.forEach(function(entry) {
                entry.parsed_created_at = moment(entry.created_at, qiitaDateFormat);
                entry.display_date = entry.parsed_created_at.format(displayYMDFormat);
                var seconds = String(Math.floor(entry.parsed_created_at.unix()));
                calData[seconds] = entry.stock_count;
                $scope.contributions += entry.stock_count;
                // calculate contriutions last year
                if (now.diff(entry.created_at, "month") < 12) {
                    contributionsLastYear += entry.stock_count;
                }
            });
            entries = dt;

            // sort by created_at asc
            var reversed = dt.slice(0).reverse();
            reversed.forEach(function(entry) {
                // var datetime = moment(entry.created_at, qiitaDateFormat),
                var datetime = entry.parsed_created_at;
                // calculate streak
                if (prevDate && prevDate.date() !== datetime.date()) {
                    var comp1 = moment([datetime.year(), datetime.month(), datetime.date()]),
                        comp2 = moment([prevDate.year(), prevDate.month(), prevDate.date()]),
                        diff = comp1.diff(comp2, "days");
                    if (diff === 1) {
                        tmpStreak += 1;
                        tmpStreakEndDate = datetime;
                    } else if (diff > 1) {
                        if (tmpStreak >= longestStreak) {
                            longestStreak = tmpStreak;
                            longestStreakEndDate = tmpStreakEndDate;
                        }
                        tmpStreak = 1;
                    }
                } else {
                    tmpStreak = 1;
                }
                prevDate = datetime;
            });
            if (tmpStreak > 0 && tmpStreak >= longestStreak) {
                longestStreak = tmpStreak;
                longestStreakEndDate = tmpStreakEndDate;
                if (!longestStreakEndDate) {
                    longestStreakEndDate = prevDate;
                }
            }
            if (prevDate && now.date() !== prevDate.date()) {
                tmpStreak = 0;
            }

            // set contribution stats
            var target = $scope.contribStats[0];
            target.count = contributionsLastYear;
            target.fromDate = moment().add(-1, "years").format(displayYMDFormat);
            target.toDate = now.format(displayYMDFormat);

            target = $scope.contribStats[1];
            if (longestStreak > 0) {
                target.count = longestStreak;
                target.unit = target.count === 1 ? "day" : "days";
                target.toDate = longestStreakEndDate.format(streakDateFormat);
                target.fromDate = moment(longestStreakEndDate).add((longestStreak - 1) * -1, "days").format(streakDateFormat);
            }

            target = $scope.contribStats[2];
            if (tmpStreak > 0) {
                target.count = tmpStreak;
                target.unit = target.count === 1 ? "day" : "days";
                target.toDate = now.format(streakDateFormat);
                target.fromDate = moment().add((tmpStreak - 1) * -1, "days").format(streakDateFormat);
            } else if (reversed.length) {
                target.last_contributed = now.diff(moment(reversed[reversed.length - 1].created_at, qiitaDateFormat), "days");
            }

            // set popular entries
            // sort by stock_count desc
            var sorted = dt.slice(0).sort(function(a, b) {
                if (a.stock_count > b.stock_count) {
                    return -1;
                }
                if (a.stock_count < b.stock_count) {
                    return 1;
                }
                return 0;
            });
            if (sorted.length < 6) {
                $scope.popularEntries = sorted;
            } else {
                $scope.popularEntries = sorted.slice(0, 5);
            }

            // set activities
            $scope.changePeriod("1 week", moment().add(-1, "weeks"));

            // setup calheatmap
            var cal = new CalHeatMap();
            cal.init({
                start: moment().add(-1, "year").add(1, "month").toDate(),
                data: calData,
                domain: "month",
                cellSize: 9,
                legendHorizontalPosition: "right",
                onClick: function(date, value) {
                    var from = moment(date);
                    var to = moment(from).add(1, "days");
                    $scope.changePeriod(from.format(displayYMDFormat), from, to);
                    $scope.$apply();
                }
            });
        });

    }]);
