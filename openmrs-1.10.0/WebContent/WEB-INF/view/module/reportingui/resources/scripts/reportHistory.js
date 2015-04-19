var runReportApp = angular.module("reportHistoryApp", ['ui.bootstrap']).
    filter('translate', function() {
        return function(input, prefix) {
            var code = prefix ? prefix + input : input;
            return emr.message(code, input);
        }
    });

runReportApp.controller('ReportHistoryController', ['$scope', '$http', '$window', '$timeout', function($scope, $http, $window, $timeout) {

    $scope.loading = true;

    $scope.queue = [];

    $scope.completed = [];

    $scope.highlight = window.highlight;

    $scope.refreshHistory = function() {
        $http.get("reportStatus/getQueuedRequests.action").
            success(function(data, status, headers, config) {
                $scope.queue = data;
                $scope.loading = false;
                if ($scope.queue.length > 0) {
                    $timeout($scope.refreshHistory, 10000);
                }
            }).
            error(function(data, status, headers, config) {
                console.log("Error getting queue: " + status);
                $scope.queue = [];
            });

        $http.get("reportStatus/getCompletedRequests.action").
            success(function(data, status, headers, config) {
                $scope.completed = data;
            }).
            error(function(data, status, headers, config) {
                console.log("Error getting completed: " + status);
                $scope.completed = [];
            });
    }

    $scope.hasResults = function() {
        return !$scope.loading && $scope.completed.length > 0;
    }

    $scope.hasNoResults = function() {
        return !$scope.loading && $scope.completed.length == 0;
    }

    var defaultSuccessAction = function(data, status, headers, config) {
        emr.successMessage(data.message);
        $scope.refreshHistory();
    }

    var defaultErrorAction = function(data, status, headers, config) {
        emr.errorMessage(data.message);
        $scope.refreshHistory();
    }

    $scope.cancelRequest = function(request) {
        $http.post("reportStatus/cancelRequest.action?reportRequest=" + request.uuid).
            success(defaultSuccessAction).
            error(defaultErrorAction);
    }

    $scope.canSave = function(request) {
        return request.status == 'COMPLETED';
    }

    $scope.saveRequest = function(request) {
        $http.post("reportStatus/saveRequest.action?reportRequest=" + request.uuid).
            success(defaultSuccessAction).
            error(defaultErrorAction);
    }

    $scope.viewStatus = function(request) {
        location.href = emr.pageLink('reportingui', 'reportStatus', { request: request.uuid });
    }

}]);