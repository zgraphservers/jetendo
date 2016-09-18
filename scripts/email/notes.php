<?php
/*
Working on email reply to jetendo system.

i figured out the basecamp reply email structure is this:

U + user id encrypted with DES algorithm + P + post id + -reply@username.basecamphq.com

DES algorithm is reversible encryption, but you need a secret string to do it.  I can implement the same, or stronger algorithm to protect against impersonating other users. They decrypt the user id and then query the database for user id and post id, which is simple.  If nothing exists in database, the email is spam and should be deleted or treated as a new thread.

It doesn't matter if you reply with a different from email, it still treats the reply as if you are the same user.  The content of the email also doesn't matter.  I tested this.

If you delete a basecamp message, any future replies by email are ignored.  No one receives them, and they are not logged in basecamp.  Basecamp also deletes the subject.  The user might have typed a subject, and we'll never see it if they reply by email.  We can handle both of these as options in new system.
	added fields for these

The encryption of the user id is the only thing protecting basecamp from getting spammed, but if the exact email was made public, spammers could get through on a single thread. 

The encryption could be updated later, without breaking old links.
 
if we make it work like craigslist, all users must be having a "From" address on the same domain or we'd have to be responsible for storing their smtp authentication password in plain text.
	useful for lead system as CRM / webmail later.
	
recommended: mail username / appId / zDESEncryptForURL(user_id, user_des_salt) / data_id / data_id2 / etc - 64 character limit 
	16 char email username limit for the routing email only
	zgraphportal+1.e254316d79b3d4e7.10243410.12353420@gmail.com
		user_des_salt (use generateSecretKey in coldfusion to set this)
		zDESDecryptForURL and zDESEncryptForURL
		thread_hash (sha256)
	don't want it to be easy to impersonate user at all
 
Some of the email code has been written in php, because lucee can't do secure imap/pop right now.  I made code that can use gmail imap to download file attachments, embedded images, decode the email format, parse out the plus address id and display the html in php.  

I'm going to make a queue for processing incoming and outgoing mail reliably so that there is a transaction for each one to avoid temporary failure causing data loss.  The outgoing queue will have separate record for each person instead of bcc, etc.

If all the mail is sent from a new sendgrid sub-user, then we can assume all bounce/blocks are related to this application.  We can integrate with their api to make it tell the user that the email to X person failed.


CREATE TABLE `queue_pop` (
  `queue_pop_id` INT(11) NOT NULL,
  `site_id` INT(11) NOT NULL,
  `queue_pop_message_uid` TEXT NOT NULL,
  `queue_pop_created_datetime` DATETIME NOT NULL,
  `queue_pop_updated_datetime` DATETIME NOT NULL,
  `queue_pop_last_run_datetime` DATETIME NOT NULL,
  `queue_pop_header_data` LONGTEXT NOT NULL,
  `queue_pop_subject` LONGTEXT NOT NULL,
  `queue_pop_body_text` LONGTEXT NOT NULL,
  `queue_pop_body_html` LONGTEXT NOT NULL,
  `queue_pop_file_list` LONGTEXT NOT NULL,
  `queue_pop_fail_count` INT(11) NOT NULL,
  `queue_pop_return_p` LONGTEXT NOT NULL,
  `queue_pop_response` LONGTEXT NOT NULL,
  `queue_pop_timeout` INT(11) NOT NULL,
  `queue_pop_retry_interval` INT(11) NOT NULL,
  `queue_pop_deleted` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`queue_pop_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8


on outgoing mail, change the return path to match the from address.  This causes the bounce notice to be recorded in the thread, to make sure that someone corrects the problem for that user.

bounce notice can't be disabled in sendgrid, if we send from sendgrid instead of gmail / outlook, we must use the event notification api instead, which sends data via http post to our custom url.
	https://sendgrid.com/docs/API_Reference/Webhooks/event.html
	like this does: https://vimmaniac.com/software/interspire_sendgrid_integration_addon/
*/
?>