package com.vuduc.android.retrofitpicassodemo;

import retrofit.Callback;
import retrofit.client.Response;
import retrofit.http.GET;

/**
 * Created by vuduc on 8/21/15.
 */
public interface SamiService {

    @GET("/thong-bao-sinh-vien")
    public void getMessages(Callback<Response> cb);

}