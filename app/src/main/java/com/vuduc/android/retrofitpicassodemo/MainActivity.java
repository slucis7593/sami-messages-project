package com.vuduc.android.retrofitpicassodemo;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TextView;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlPullParserFactory;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringReader;

import retrofit.Callback;
import retrofit.RestAdapter;
import retrofit.RetrofitError;
import retrofit.client.Response;

public class MainActivity extends AppCompatActivity {

    public static final String END_POINT = "http://sami.hust.edu.vn";
    private static final String TAG = MainActivity.class.getSimpleName();
    private static final String XML_DIV = "div";
    private static final String CLASS_ARTICLE_INFO = "article-info";
    private static final String CLASS_DATE = "date-repeat-instance";
    private static final String CLASS_TITLE = "article-title";

    private TextView mTVContent;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mTVContent = (TextView) findViewById(R.id.tvContent_main);

        RestAdapter restAdapter = new RestAdapter.Builder()
                .setEndpoint(END_POINT)
                .build();

        SamiService samiService = restAdapter.create(SamiService.class);

        samiService.getMessages(new Callback<Response>() {
            @Override
            public void success(Response result, Response response) {
                //Try to get response body
                BufferedReader reader = null;
                StringBuilder sb = new StringBuilder();
                try {

                    reader = new BufferedReader(new InputStreamReader(result.getBody().in()));

                    String line;

                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                } catch (IOException e) {
                    Log.e(TAG, "Fail to read Response: ", e);
                }


                String xmlString = sb.toString();

                parseXMLString(xmlString);
            }

            @Override
            public void failure(RetrofitError retrofitError) {
                mTVContent.setText(retrofitError.toString());
            }
        });

    }

    private void parseXMLString(String xmlString) {
        String date = "";
        String url = "";
        String title = "";

        Document doc = Jsoup.parse(xmlString);

        // First element
        Element firstElement = doc.getElementsByClass(CLASS_ARTICLE_INFO).get(0);

        // Date
        date = firstElement.getElementsByClass(CLASS_DATE).get(0).text();

        // Title and url
        Element titleElement = firstElement.getElementsByClass(CLASS_TITLE).get(0);
        url = titleElement.getElementsByTag("a").get(0).attr("href");
        title = titleElement.text();

        mTVContent.setText(date + "\n" + title + "\n" + url);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
