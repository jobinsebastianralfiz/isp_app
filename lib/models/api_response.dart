enum Status { loading, completed, error }

class ApiResponse<T> {
  Status status;
  T? data;
  String? message;

  ApiResponse.loading() : status = Status.loading;
  ApiResponse.completed(this.data) : status = Status.completed;
  ApiResponse.error(this.message) : status = Status.error;

  bool get isLoading => status == Status.loading;
  bool get isCompleted => status == Status.completed;
  bool get isError => status == Status.error;
}