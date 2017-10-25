 function getAllStudentByPage(callBack, pageSize, pageNum) {
    Visualforce.remoting.Manager.invokeAction(
        '{!$RemoteAction.SM_StudentCC.queryStudentPagination}',
            pageSize, pageNum, callBack, {'escape': false}
    );
}

function changeSelectedStatus(callback, studentList, selectedStatus) {
    Visualforce.remoting.Manager.invokeAction(
        '{!$RemoteAction.SM_StudentCC.changeSelectedStatus}',
            studentList, selectedStatus, callback, {'escape': false}
    );
}


function redirectToImportWizard() {
    window.location.href = 'https://mulodo-recruitment-dev-ed.lightning.force.com/one/one.app?source=aloha#eyJjb21wb25lbnREZWYiOiJvbmU6YWxvaGFQYWdlIiwiYXR0cmlidXRlcyI6eyJ2YWx1ZXMiOnsiYWRkcmVzcyI6Ii91aS9zZXR1cC9kYXRhaW1wb3J0ZXIvRGF0YUltcG9ydGVyQWRtaW5MYW5kaW5nUGFnZT9yZXRVUkw9JTJGc2V0dXAlMkZob21lJnZmUmV0VVJMSW5TRlg9aHR0cHMlM0ElMkYlMkZtdWxvZG8tcmVjcnVpdG1lbnQtZGV2LWVkLmxpZ2h0bmluZy5mb3JjZS5jb20lMkZvbmUlMkZvbmUuYXBwJTNGc291cmNlJTNEYWxvaGElMjMlMkZzZXR1cCUyRnBhZ2UlM0Zub2RlSWQlM0RMYWJlbFdvcmtiZW5jaFNldHVwJTI2YWRkcmVzcyUzRCUyNTJGaTE4biUyNTJGVHJhbnNsYXRpb25TcGxhc2guYXBleHAlMjUzRnJldFVSTCUyNTNEJTI1MjUyRnNldHVwJTI1MjUyRmhvbWUlMjZhJTNBdCUzRDE1MDc4NzY3MjIxODciLCJoYXNIaXN0b3J5Ijp0cnVlfX0sImE6dCI6MTUwNzg3NjcyMzQ3MX0%3D'; // link to import page
}

function popupCustomImportWizard() {
    let newwindow = window.open('https://mulodo-recruitment-dev-ed--c.ap5.visual.force.com/apex/SM_ImportCSVWizardPage', 'Custom Import Wizard', 'height=400, width=400');
    if (window.focus) {
        newwindow.focus()
    }

}

angular.module('mainApp', [])
        .factory('VFRemotingFactory', ($q, $rootScope) => {
            const factory = {};
            factory.getData = (pageSize, pageNum) => {
                let deferred = $q.defer();
                getAllStudentByPage((res) => {
                    $rootScope.$apply(() => {
                        deferred.resolve(res)
                    })
                }, pageSize, pageNum);
                return deferred.promise;
            };
            factory.changeSelectedStatus = (studentIdList, selectedStatus) => {
                let deferred = $q.defer();
                changeSelectedStatus((res) => {
                    deferred.resolve(res) // method from controller return void
                }, studentIdList, selectedStatus);
                return deferred.promise;
            };
            return factory;
        })
        .factory('NotificationService', function() {
            var messageQueues = [];
            return {
                pushNewMessage: function(message) {
                    messageQueues = [...messageQueues, message]
                },
                getMessages: function() {
                    return messageQueues;
                },
                removeReadMessage: function() {
                    messageQueues = messageQueues.slice(1); // remove the first item in list
                }
            }
        })
        .controller('listStudentController', ['$scope', 'VFRemotingFactory', 'NotificationService', ($scope, VFRemotingFactory, NotificationService) => {
            // declaration
            $scope.pageSize = 5; // default page size
            $scope.currentPage = 0; // default current page
            $scope.pageSizeOption = [5, 10 , 20]; // pageSizeOption Setup here
            $scope.isModalOpen = false; // UI Control of modal pop up
            $scope.selectedList = new Set(); // UI Control of Selected List
            $scope.isDropdownOpen = false; // UI Control pick list open status
            $scope.statusPickList = '{!statusPickList}'; // Status Pick List
            $scope.selectedStatusOption = null; // value of selected status
            $scope.totalRecord = '{!totalRecord}'; // number of total records
            $scope.lastPage =  Math.floor($scope.totalRecord / $scope.pageSize); // calculate the lastPage number
//                    console.log('$scope: ', $scope.statusPickList);

            $scope.initData = () => {
                VFRemotingFactory.getData($scope.pageSize, $scope.currentPage).then(res => {
                    $scope.students = [...res];
                });
            };

            $scope.initData(); // init data call at init controller
//                    $scope.students = StudentService.getStudentList();
            // init - constructor

            // event declaration
            $scope.onChangeStatusClick = () => {
                if ($scope.selectedList.size === 0) {
                    alert('You should selected at least 1 student to change status');
                    return;
                }
                $scope.isModalOpen = true;
            };

            // close modal click (include cancel button) too
            $scope.onCloseModalClick = () => {
                $scope.isModalOpen = false;
            };

            // save click
            $scope.onSaveModalClick = () => {
                VFRemotingFactory.changeSelectedStatus(
                    JSON.stringify([...$scope.selectedList]),
                        $scope.selectedStatusOption
                ).then(res => {
                    if (res) {
                        var successMessage = {
                            severity: 'success',
                            message: 'Change Status Completed!'
                        }
                        NotificationService.pushNewMessage(successMessage);
                    }
                });
                $scope.initData();
                $scope.selectedList = new Set(); // reset selected list
                $scope.isModalOpen = false; // close modal after complete
            };

            // toggle status pick list
            $scope.onToggleStatusPickList = () => {
                $scope.isDropdownOpen = !$scope.isDropdownOpen;
            };

            // on select pick list status option
            $scope.onSelectStatusOption = (option) => {
                $scope.selectedStatusOption = option;
                $scope.isDropdownOpen = false;
            };

            // on select student on list event
            $scope.onSelectStudent = (id) => {
                if (!$scope.selectedList.has(id)) {
                    $scope.selectedList.add(id);
                } else {
                    $scope.selectedList.delete(id);
                }
            };

            $scope.onPageSizeChange = () => {
                $scope.lastPage = Math.floor($scope.totalRecord / $scope.pageSize); // recalculate the last page when $scope.pageSize change
                $scope.initData(); // whenever change pageSize or number of Page ==> request list again
            };

            $scope.onChangePageNumber = (pageNumber) => {
                $scope.currentPage = pageNumber;
                $scope.initData();
            };


        }])
        .controller('toastController', ['$scope', 'NotificationService', ($scope, NotificationService) => {
            $scope.$watchCollection(function() {return NotificationService.getMessages()}, function(newValue, oldValue) {
                $scope.notifications = newValue;
            })
            $scope.markMessageAsRead = () => {
                NotificationService.removeReadMessage();
            }
            $scope.checkSeverity = (status) => {
                console.log($scope.notifications[0].severity === status);
                return $scope.notifications[0].severity === status;
            }
        }]);
