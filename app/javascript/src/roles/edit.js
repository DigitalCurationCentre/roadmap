import { renderNotice, renderAlert } from '../utils/notificationHelper';
import { isString, isObject } from '../utils/isType';
import { scrollTo } from '../utils/scrollTo';

$(() => {
  $('form.edit_role select').on('change', (e) => {
    $(e.target).closest('form').submit();
  });
  $('form.edit_role').on('ajax:success', (e) => {
    const data = e.detail[0];
    if (isObject(data) && isString(data.msg)) {
      renderNotice(data.msg);
      scrollTo('#notification-area');
    }
  });
  $('form.edit_role').on('ajax:error', (e) => {
    if (isObject(e.detail[2])) {
      const error = e.detail[2].responseJSON;
      if (isObject(error) && isString(error)) {
        renderAlert(error.msg);
        scrollTo('#notification-area');
      }
    }
  });
});
