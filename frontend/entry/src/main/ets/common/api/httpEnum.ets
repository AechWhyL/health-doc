/**
 * @description: Request result set
 */

export enum ResultEnum {
  SUCCESS = 200,
  ERROR = 1,
  UNAUTHORIZED = 401,
}

/**
 * @description: request method
 */
export enum RequestEnum {
  GET = "get",
  POST = "post",
  PUT = "put",
  DELETE = "delete",
  PATCH = "patch"
}

/**
 * @description:  contentType
 */
export enum ContentTypeEnum {
  // json
  JSON = "application/json;charset=UTF-8",
  // form-data qs
  FORM_URLENCODED = "application/x-www-form-urlencoded;charset=UTF-8",
  // form-data  upload
  FORM_DATA = "multipart/form-data;charset=UTF-8",
}

/**
 * baseUrl
 */
export enum BASEURL {
  // baseUrl = 'http://localhost:3000'
  baseUrl = 'http://10.0.2.2:3000'
}