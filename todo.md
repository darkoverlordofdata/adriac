# todo

this is version 0.1

ideas for version 0.2

## 1 - headers

Is putting everything into a header and making it all static inline the best way to do this? probably not. I should revert to a *.c/*.h modular structure. This will help the next item:

## 2 - malloc

My version of gmem and glice are just wrappers for the builtin malloc/free. I'm not too comfortable with the original glib version, I prefer Doug Lea's malloc. And I really need to restructure the code as in item 1 to merge it in.

## 3 - vapis

I want to support snake/notSnake, so to_string and ToString should both work. This will make code more portable with std vala.
