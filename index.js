import {
    NativeModules,
    DeviceEventEmitter
} from 'react-native';

const RongCloudIMLib = NativeModules.RongCloudIMLibModule;

var _onRongCloudMessageReceived = function(resp) {

}
DeviceEventEmitter.addListener('onRongCloudMessageReceived', resp => {
    typeof _onRongCloudMessageReceived === 'function' && _onRongCloudMessageReceived(resp);
});

const ConversationType = {
    PRIVATE: 'PRIVATE',
    DISCUSSION: 'DISCUSSION',
    SYSTEM: 'SYSTEM'
};

export default {
    ConversationType: ConversationType,
    onReceived (callback) {
        _onRongCloudMessageReceived = callback;
    },
    initWithAppKey (appKey) {
        return RongCloudIMLib.initWithAppKey(appKey);
    },
    connectWithToken (token) {
        return RongCloudIMLib.connectWithToken(token);
    },
    //获得会话列表
    getConversationList (){
        return RongCloudIMLib.getConversationList();
    },
    //获得会话中的聊天信息
    getRemoteHistoryMessages(RCConversationType, targetId, recordTime, count){
        return RongCloudIMLib.getRemoteHistoryMessages(RCConversationType, targetId, recordTime, count);
    },
    /*!
     获取会话中，从指定消息之前、指定数量的最新消息实体
     
     @param conversationType    会话类型
     @param targetId            目标会话ID
     @param oldestMessageId     截止的消息ID
     @param count               需要获取的消息数量
     @return                    消息实体RCMessage对象列表
     
     @discussion 此方法会获取该会话中，oldestMessageId之前的、指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
     返回的消息中不包含oldestMessageId对应那条消息，如果会话中的消息数量小于参数count的值，会将该会话中的所有消息返回。
     如：
     oldestMessageId为10，count为2，会返回messageId为9和8的RCMessage对象列表。
     */
    getHistoryMessages(conversationType, targetId, oldestMessageId, count){
        return RongCloudIMLib.getHistoryMessages(conversationType, targetId, oldestMessageId, count);
    },
    /*!
     获取某个会话中指定数量的最新消息实体
     
     @param conversationType    会话类型
     @param targetId            目标会话ID
     @param count               需要获取的消息数量
     @return                    消息实体RCMessage对象列表
     
     @discussion 此方法会获取该会话中指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
     如果会话中的消息数量小于参数count的值，会将该会话中的所有消息返回。
     */
    getLatestMessages(conversationType, targetId, count){
        return RongCloudIMLib.getLatestMessages(conversationType, targetId, count);
    },

    //发送消息
    sendTextMessage (conversationType, targetId, content) {
        return RongCloudIMLib.sendTextMessage(conversationType, targetId, content, content);
    },
    
};
