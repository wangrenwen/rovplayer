package utils
{
	/**
	 * @Script:		HTTPResponse.as
	 * @Licence:	MIT License (http://www.opensource.org/licenses/mit-license.php)
	 * @Author: 	xushengs@gmail.com
	 * @Website: 	http://code.google.com/p/fookie/
	 * @Version: 	0.1
	 * @Creation: 	Sep 27, 2010
	 * @Modified: 	Sep 27, 2010
	 * @Description:
	 *    HTTPResponse Object
	 */
	
	public class HTTPResponse
	{
		public function get headers():Object
		{
			return _headers;
		}
		
		public function get status():int
		{
			return _status;
		}
		
		public function get body():String
		{
			return _body;
		}
		
		public function get content():String
		{
			return _body;
		}
		
		private var _headers:Object = {};
		private var _status:int = 0;
		private var _body:String = '';
		
		public function HTTPResponse(response:Object)
		{
			this._headers = response.headers;
			this._status = response.status;
			this._body = response.body;
		}
	}
}