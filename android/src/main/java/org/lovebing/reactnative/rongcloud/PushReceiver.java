package org.lovebing.reactnative.rongcloud;

import android.content.Context;

import io.rong.imlib.ipc.PushMessageReceiver;
import io.rong.notification.PushNotificationMessage;


/**
 * Created by lgp on 2017/7/3.
 */

public class PushReceiver extends PushMessageReceiver {

    public boolean onNotificationMessageArrived(Context context, PushNotificationMessage message) {
        return false;
    }

    public boolean onNotificationMessageClicked(Context context, PushNotificationMessage message) {
        return false;
    }
}
