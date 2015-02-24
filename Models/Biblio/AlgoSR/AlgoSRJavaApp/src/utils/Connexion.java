/**
 * 
 */
package utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.protocol.HttpContext;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 * Basic method to handle connections
 */
public class Connexion {
	
public static HttpResponse get(String url,HttpContext context){
	    DefaultHttpClient client = new DefaultHttpClient();	
		try{
			HttpGet httpGet = new HttpGet(url);
			return client.execute(httpGet,context);
		}
		catch(Exception e){e.printStackTrace();return null;}
	}
	
	
	
	
	/**
	 * 
	 * Simple Post Request
	 * 
	 * @param url
	 * @param data
	 * @param context : context externally provided to store cookies e.g.
	 * @return
	 */
	public static HttpResponse post(String url,HashMap<String,String> headers,HashMap<String,String> data,HttpContext context){
		DefaultHttpClient client = new DefaultHttpClient();			
		try{
			HttpPost httpPost = new HttpPost(url);
			for(String k:headers.keySet()){httpPost.setHeader(k, headers.get(k));}
			httpPost.setParams((new BasicHttpParams()).setParameter("http.protocol.handle-redirects",false));
			List <NameValuePair> nvps = new ArrayList <NameValuePair>();
			for(String k:data.keySet()){nvps.add(new BasicNameValuePair(k, data.get(k)));}
			httpPost.setEntity(new UrlEncodedFormEntity(nvps));
			return client.execute(httpPost,context);
		}
		catch(Exception e){e.printStackTrace();return null;}
	}
	
	
}
