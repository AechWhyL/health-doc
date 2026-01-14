import { setBaseUrl } from './HttpUtil';

export class ApiService {

  constructor() {
    setBaseUrl('http://localhost:3000');
  }
}

export default new ApiService();
