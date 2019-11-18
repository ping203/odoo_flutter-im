
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'widget_util.dart';

import '../../util/style.dart';
import '../../util/time.dart';
import '../../util/user_info_datesource.dart';

class ConversationListItem extends StatefulWidget {
  final Conversation conversation;
  final ConversationListItemDelegate delegate;
  const ConversationListItem({Key key,this.delegate, this.conversation}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return new _ConversationListItemState(this.delegate,this.conversation);
  }
}

class _ConversationListItemState extends State<ConversationListItem> {
  Conversation conversation ;
  ConversationListItemDelegate delegate;
  UserInfo user;
  Offset tapPos;
  _ConversationListItemState(ConversationListItemDelegate delegate,Conversation con) {
    this.delegate = delegate;
    this.conversation = con;
    String targetId=con.targetId;
    this.user = UserInfoDataSource.getUserInfo(targetId);
  }
  
  void _onTaped() {
    if(this.delegate != null) {
      this.delegate.didTapConversation(this.conversation);
    }else {
      print("没有实现 ConversationListItemDelegate");
    }
  }

  void _onLongPressed() {
    if(this.delegate != null) {
      this.delegate.didLongPressConversation(this.conversation,this.tapPos);
    }else {
      print("没有实现 ConversationListItemDelegate");
    }
  }

  Widget _buildPortrait() {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: 8,
            ),
            WidgetUtil.buildUserPortrait(this.user.portraitUrl),
          ],
        ),
        Positioned(
          right:-3.0 ,
          top: -3.0,
          child: _buildUnreadCount(conversation.unreadMessageCount),
        ),
      ],
    );
  }

  Widget _buildContent(){
    return Expanded(
      child: Container(
        height: RCLayout.ConListItemHeight,
        margin: EdgeInsets.only(left:8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.5,color: Color(RCColor.ConListBorderColor),)
          )
        ),
        child: Row(
          children: <Widget>[
            _buildTitle(),
            _buildTime()
          ],
        ),
      ),
    );
  }

  Widget _buildTime(){
    String time = TimeUtil.convertTime(conversation.sentTime);
    List<Widget> _rightArea =<Widget>[
      Text(time,style:TextStyle(fontSize: RCFont.ConListTimeFont,color: Color(RCColor.ConListTimeColor))),
      SizedBox(height: 15,)
    ];
    return Container(
      width:RCLayout.ConListItemHeight,
      margin: EdgeInsets.only(right: 8),
      child: Column(
        mainAxisAlignment:  MainAxisAlignment.center,
        children: _rightArea
      ),
    );
  }

  Widget _buildTitle(){
    String title = this.user.name;
    String digest = "";
    if(conversation.latestMessageContent != null) {
      digest = conversation.latestMessageContent.conversationDigest();
    }
    if(digest == null) {
      digest = "";
    }
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: RCFont.ConListTitleFont,color: Color(RCColor.ConListTitleColor),fontWeight:FontWeight.w400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6,),
          Text(
            digest,
            style: TextStyle(fontSize: RCFont.ConListDigestFont,color: Color(RCColor.ConListDigestColor)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _buildUnreadCount(int count) {
    if(count <=0 || count == null) {
      return WidgetUtil.buildEmptyWidget();
    }
    return Container(
      width: RCLayout.ConListUnreadSize,
      height: RCLayout.ConListUnreadSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RCLayout.ConListUnreadSize/2.0),
        color: Color(RCColor.ConListUnreadColor)
      ),
      child: Text(count.toString(),style:TextStyle(fontSize: RCFont.ConListUnreadFont,color: Color(RCColor.ConListUnreadTextColor)))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(RCColor.ConListItemBgColor),
      child: InkWell(
        onTapDown: (TapDownDetails details) {
          tapPos = details.globalPosition;
        },
        onTap: () {
          _onTaped();
        },
        onLongPress: () {
          _onLongPressed();
        },
        child: Container(
          height: RCLayout.ConListItemHeight,
          color: Color(RCColor.ConListItemBgColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildPortrait(),
              _buildContent()
            ],
          ),
        ),
      ),
    );
  }
}

abstract class ConversationListItemDelegate {
  ///点击了会话 item
  void didTapConversation(Conversation conversation);
  ///长按了会话 item
  void didLongPressConversation(Conversation conversation,Offset tapPos);
}