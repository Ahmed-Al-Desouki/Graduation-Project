using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Common
{
    public class ServiceResult
    {
        public bool IsSuccess { get; private set; }
        public string? Error { get; private set; }

        public static ServiceResult Success() => new() { IsSuccess = true };
        public static ServiceResult Failure(string error) => new() { IsSuccess = false, Error = error };
    }

    public class ServiceResult<T>
    {
        public bool IsSuccess { get; private set; }
        public T? Data { get; private set; }
        public string? Error { get; private set; }

        public static ServiceResult<T> Success(T data) => new() { IsSuccess = true, Data = data };
        public static ServiceResult<T> Failure(string error) => new() { IsSuccess = false, Error = error };
    }
}
