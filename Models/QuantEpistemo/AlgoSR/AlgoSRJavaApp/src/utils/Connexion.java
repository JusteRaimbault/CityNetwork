/**
 * 
 */
package utils;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.mime.FormBodyPart;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.entity.mime.content.ContentBody;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.entity.mime.content.StringBody;
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
	
public static HttpResponse get(String url,HashMap<String,String> headers,DefaultHttpClient client,HttpContext context){	
		try{
			HttpGet httpGet = new HttpGet(url);
			for(String k:headers.keySet()){httpGet.setHeader(k, headers.get(k));}
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
	public static HttpResponse post(String url,HashMap<String,String> headers,HashMap<String,String> data,DefaultHttpClient client,HttpContext context){
				
		try{
			HttpPost httpPost = new HttpPost(url);
			for(String k:headers.keySet()){httpPost.setHeader(k, headers.get(k));}
			//httpPost.setParams((new BasicHttpParams()).setParameter("http.protocol.handle-redirects",false));
			List <NameValuePair> nvps = new ArrayList <NameValuePair>();
			for(String k:data.keySet()){nvps.add(new BasicNameValuePair(k, data.get(k)));}
			httpPost.setEntity(new UrlEncodedFormEntity(nvps));
			
			return client.execute(httpPost,context);
		}
		catch(Exception e){e.printStackTrace();return null;}
	}
	
	
	/**
	 * 
	 * Post request with File Upload.
	 * 
	 * NO HEADERS AS MULTIPART SUBMISSION SHOULD CREATE ITSELF.
	 * 
	 * @param url
	 * @param headers
	 * @param data
	 * @param filePath
	 * @param client
	 * @param context
	 * 
	 * @return
	 */
	public static HttpResponse postUpload(String url,HashMap<String,String> data,String filePath,DefaultHttpClient client,HttpContext context){

		try{
			HttpPost httpPost = new HttpPost(url);
		    
			MultipartEntityBuilder builder = MultipartEntityBuilder.create();
		    for(String k:data.keySet()){
		    	builder.addTextBody(k,data.get(k));
			}
		    builder.addBinaryBody("files[]", new File(filePath), ContentType.create("application/zip"), filePath).build();
		    
		    //builder.build().writeTo(System.out);
		    //System.out.println(builder.build().getContentLength());
		    httpPost.setEntity(builder.build());
		    
		    //httpPost.setHeader("Content-Length",Long.toString(builder.build().getContentLength()));
		    
		    //System.out.println(httpPost.getHeaders("Content-Length")[0].toString());
		    for(Header h:httpPost.getAllHeaders()){System.out.println(h);}
		    
			return client.execute(httpPost,context);
		}
		catch(Exception e){e.printStackTrace();return null;}
	
	}
	
	
	
	
	
	
	
}
