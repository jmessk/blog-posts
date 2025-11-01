---
title: Rust の文字列理解の続き（データ構造、メモリ、型強制）
category: tech
tags: [rust, c]
---

## はじめに

以前 Rust の文字列について記事を書いたが、不明な点が残っていたため調べた。

## C言語での文字列

C言語では文字列を表すのに `char` 配列を使う。次の例を見てみる。

```c
char *str_a   = "abc";
char  str_b[] = "abc";
```

ダブルクオークで作ったリテラルは、実行すると静的領域に確保される。`str_a` は静的領域に存在する static(実行の最初から最後まで存在する) な `char` 配列へのポインタであり、正式な型名は `const char*` である。よって次のように書き換えた方がいいかもしれない。

```c
const char *str_a = "abc";
```

`str_b` は、この変数がスタックに積まれる時に、静的領域に確保された文字列の長さ分の領域が確保され、その領域に静的領域の文字列をコピーする。よって次のようにも書け、スタックに新たに領域を確保するので文字列を変更することができる。

```c
char str_b[4] = "abc";
str_b[1] = 'x' // "axb"
```

## `&str` について

Rust におけるプリミティブ型の文字列で、文字列スライスと呼ばれる。リテラルの場合は C言語同様コンパイル時に計算され静的領域に確保される。リテラルは `&'static str` という型となり、固定長で変更不可である。

中身は `[u8]` だが、`str` の場合は値が UTF-8 であることが保証されている。実装されている文字列操作系のメソッドは少ない。

## `String` について

`String` 型は `std` で定義され，可変な文字列を表す型である。中身は `Vec` であり、実行時にはヒープ領域に確保される。

多くの文字列操作のためのメソッドが実装されている。文字列の変更が頻繁に起こる場合はこちらを使った方がいい。

## `&str` と `String` の相互変換

二つの文字列方は相互に変換できる。

### `&str` から `String`

```rust
let s = String::from("abc");
let s = "abc".to_string();
let s: String = "abc".to_owned();
let s: String = "abc".into();
```

主に上の 2 つをよく使うと思うが、実装は次のようになっていて全て等価である。

```rust:from()
impl From<&str> for String {
    /// Converts a `&str` into a [`String`].
    ///
    /// The result is allocated on the heap.
    #[inline]
    fn from(s: &str) -> String {
        s.to_owned()
    }
}
```

```rust:to_string()
impl ToString for str {
    #[inline]
    fn to_string(&self) -> String {
        String::from(self)
    }
}
```

`into()` メソッドは型推論に基づいて型変換を行うメソッドで、 `from()` メソッドが実装されているので自動的に実装される。`into()` メソッドの場合は型推論が可能でなければならない。

### `String` から `&str`

まずは `String` の定義を確認する。

```rust
pub struct String {
    vec: Vec<u8>,
}
```

`Vec` をラップした構造になっており、ヒープに確保されることがわかる。また `&str` 同様、中身が UTF-8 であることが保証されている。

```rust
let s = String::from("abc").as_str();
let s: &str = &("abc".to_string());
let s = &s[..];
```

Rust では `as_...` で始まるメソッドは所有権の移動を伴わない型変換を表す。そのため `as_str()` メソッドを使ったとしても、変換元の文字列は利用できる。これらの場合では、ヒープ上の [u8] への参照を保持していることになる。

## 型強制

次のような関数を定義したとする。

```rust
fn example(s: &String) {
    println!("{}", s)
}

fn main() {
    let s = String::from("abc");
    example(&s);
}
```

すると、clippy などの linter では次のように修正することを勧められる。

```rust
fn example(s: &str) { // 仮引数の型を変更
    println!("{}", s)
}

fn main() {
    let s = String::from("abc");
    example(&s);
}
```

どちらの定義でも同じように使うことができるが、修正した 2 つ目の関数では `&str` と `&String` 両方を引数にすることができる。これは Rust の型強制という仕組みが働くためで、柔軟な関数の利用を実現している。

`String` 以外でも、`&Vec<T>` は `&[T]` にすることができる。

仮引数だけでなく、変数の宣言などでも同様である。

```rust
let s = String::from("abc");
let s_ref = &s;       // &String
let s_str: &str = &s; // &str
```

ただし、型注釈がない場合はただの参照になってしまうので注意しなければならない。

これは `Deref` や `DerefMut` を実装しているためで、型強制が利用できる場合はコンパイラが自動的に `deref()` メソッドを使ってくれるようだ。

## まとめ

Rust の文字列と周辺について調査した。
