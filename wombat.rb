#!/usr/bin/env bash
# -*- mode: ruby; -*-

# wombat.rb
# copyright (c) 2020 by Andrei Borac

NIL2=\
=begin
exec env -i PATH="$(echo /{usr/{local/,},}{s,}bin | tr ' ' ':')" ruby -E BINARY:BINARY -I . -e 'load("'"$0"'");' -- "$@"
=end
nil;

require("strscan");

def is_identifier(token)
  return (/^[a-zA-Z_][a-zA-Z0-9_-]*$/.match(token).nil?.!);
end

def tokenize(filename, codes)
  s = StringScanner.new(codes);
  t = [];
  
  lineno = 1;
  adjust = 0;
  
  while (s.eos?.!)
    # skip whitespace
    while (true)
      next if s.scan(/[ \t\v]+/);
      
      if s.scan(/\n/)
        lineno += 1;
        adjust = s.pos;
        next;
      end
      
      break;
    end
    
    break if (s.eos?);
    
    # receive comment
    if s.scan(/;[^\n]+/)
      next;
    end
    
    # receive "("
    if s.scan(/\(/)
      t << [ :openparen, s.matched, filename, lineno, (s.pos - s.matched_size - adjust) ];
      next;
    end
    
    # receive ")"
    if s.scan(/\)/)
      t << [ :closeparen, s.matched, filename, lineno, (s.pos - s.matched_size - adjust) ];
      next;
    end
    
    # receive identifier
    if s.scan(/[a-zA-Z_][a-zA-Z0-9_-]*/)
      was_keyword = false;
      
      # handle keywords
      [
        [ "require", :require ],
        [ "defun", :defun ],
        [ "let", :let ],
        [ "lambda", :lambda ],
        [ "case", :case ],
        [ "progn", :progn ],
        [ "selfcall", :selfcall ],
        [ "Blob", :blobcall ],
      ].each{|strlbl|
        str, lbl, = strlbl;
        
        if (s.matched == str)
          t << [ lbl, s.matched, filename, lineno, (s.pos - s.matched_size - adjust) ];
          was_keyword = true;
          break;
        end
      };
      
      next if (was_keyword);
      
      t << [ :identifier, s.matched, filename, lineno, (s.pos - s.matched_size - adjust) ];
      next;
    end
    
    # receive string
    if s.scan(/"[^"]*"/)
      t << [ :stringliteral, s.matched, filename, lineno, (s.pos - s.matched_size - adjust) ];
      next;
    end
    
    # could not receive a token
    raise("bad token at filename=#{filename} lineno=#{lineno} column=#{s.pos - adjust}");
  end
  
  return t;
end

def eliminate_require_lisp(inp)
  inp = inp.clone;
  
  out = [];
  
  while (inp.empty?.!)
    if ((inp.length >= 4) &&
        (inp[0][0] == :openparen) &&
        (inp[1][0] == :require) &&
        (inp[2][0] == :stringliteral) &&
        (inp[2][1].end_with?(".lisp\"")) &&
        (inp[3][0] == :closeparen))
      out += tokenize(inp[2][1][1..-2], IO.read(inp[2][1][1..-2]));
      4.times{ inp.shift; };
    else
      out << inp.shift;
    end
  end
  
  return out;
end

def handle_require_ruby(inp)
  inp = inp.clone;
  
  out = [];
  
  while (inp.empty?.!)
    if ((inp.length >= 4) &&
        (inp[0][0] == :openparen) &&
        (inp[1][0] == :require) &&
        (inp[2][0] == :stringliteral) &&
        (inp[2][1].end_with?(".rb\"")) &&
        (inp[3][0] == :closeparen))
      load(inp[2][1][1..-2]);
      4.times{ inp.shift; };
    else
      out << inp.shift;
    end
  end
  
  return out;
end

def force_peek(inp)
  raise("unexpected end of stream") if (inp.empty?);
  return inp[0];
end

def force_shift(inp)
  raise("unexpected end of stream") if (inp.empty?);
  return inp.shift;
end

def force_peek_expect(inp, kind)
  token = force_peek(inp);
  raise("expected #{kind} token at filename=#{token[2]} lineno=#{token[3]} column=#{token[4]}") if (!(token[0] == kind));
  return token;
end

def force_shift_expect(inp, kind)
  token = force_shift(inp);
  raise("expected #{kind} token at filename=#{token[2]} lineno=#{token[3]} column=#{token[4]}") if (!(token[0] == kind));
  return token;
end

$tokenmap = {};

def tokenmapify(token)
  match = token[1];
  $tokenmap[match.object_id] = token;
  return match;
end

def parse_formals(inp)
  formals = [];
  
  while (true)
    token = force_shift(inp);
    case token[0]
    when :closeparen
      break
    when :identifier
      formals << tokenmapify(token);
    else
      raise("expected closeparen or identifier token at filename=#{token[2]} lineno=#{token[3]} column=#{token[4]}");
    end
  end
  
  return formals;
end

def parse_parenthesized_expression(inp)
  token = force_shift(inp);
  
  case token[0]
  when :let
    force_shift_expect(inp, :openparen);
    bindings = [];
    while (force_peek(inp)[0] == :openparen)
      force_shift_expect(inp, :openparen);
      bindings << [ tokenmapify(force_shift_expect(inp, :identifier)), parse_expression(inp) ];
      force_shift_expect(inp, :closeparen);
    end
    force_shift_expect(inp, :closeparen);
    body = parse_expression(inp);
    force_shift_expect(inp, :closeparen);
    return [ :let, tokenmapify(token), bindings, body ];
  when :lambda
    force_shift_expect(inp, :openparen);
    formals = parse_formals(inp);
    body = parse_expression(inp);
    force_shift_expect(inp, :closeparen);
    return [ :lambda, tokenmapify(token), formals, body ];
  when :case
    expr = parse_expression(inp);
    force_peek_expect(inp, :openparen);
    cases = [];
    while (force_peek(inp)[0] != :closeparen)
      force_shift_expect(inp, :openparen);
      force_shift_expect(inp, :openparen);
      constructor = force_shift_expect(inp, :identifier);
      bindings = [];
      while (force_peek(inp)[0] != :closeparen)
        bindings << tokenmapify(force_shift_expect(inp, :identifier));
      end
      force_shift_expect(inp, :closeparen);
      expr2 = parse_expression(inp);
      cases << [ tokenmapify(constructor), bindings, expr2 ];
      force_shift_expect(inp, :closeparen);
    end
    force_shift_expect(inp, :closeparen);
    return [ :case, tokenmapify(token), expr, cases ];
  when :progn
    exprs = [];
    while (force_peek(inp)[0] != :closeparen)
      exprs << parse_expression(inp);
    end
    force_shift_expect(inp, :closeparen);
    return [ :progn, tokenmapify(token), exprs ];
  when :blobcall # blobcall
    exprs = [ [ :blobcall, tokenmapify(token) ] ];
    while (force_peek(inp)[0] != :closeparen)
      exprs << parse_expression(inp);
    end
    force_shift_expect(inp, :closeparen);
    return [ :funcall, tokenmapify(token), exprs ];
  when :selfcall # selfcall
    exprs = [ [ :selfcall, tokenmapify(token) ] ];
    while (force_peek(inp)[0] != :closeparen)
      exprs << parse_expression(inp);
    end
    force_shift_expect(inp, :closeparen);
    return [ :funcall, tokenmapify(token), exprs ];
  when :identifier # funcall
    exprs = [ [ :identifier, tokenmapify(token) ] ];
    while (force_peek(inp)[0] != :closeparen)
      exprs << parse_expression(inp);
    end
    force_shift_expect(inp, :closeparen);
    return [ :funcall, tokenmapify(token), exprs ];
  when :openparen # funcall computed function
    exprs = [ parse_parenthesized_expression(inp) ];
    while (force_peek(inp)[0] != :closeparen)
      exprs << parse_expression(inp);
    end
    raise if (!(force_shift(tokens) == ")"));
    return [ :funcall, tokenmapify(token), exprs ];
  end
end

def parse_expression(inp)
  token = force_shift(inp);
  
  case token[0]
  when :openparen
    return parse_parenthesized_expression(inp);
  when :identifier
    return [ :identifier, tokenmapify(token) ];
  else
    raise("unexpected token at filename=#{token[2]} lineno=#{token[3]} column=#{token[4]}");
  end
end

def parse_defun(inp)
  force_shift_expect(inp, :openparen);
  defun = force_shift_expect(inp, :defun);
  funname = force_shift_expect(inp, :identifier);
  force_shift_expect(inp, :openparen);
  formals = parse_formals(inp);
  funbody = parse_expression(inp);
  force_shift_expect(inp, :closeparen);
  return [ :defun, tokenmapify(defun), tokenmapify(funname), formals, funbody ];
end

def parse_expressions(inp)
  inp = inp.clone;
  
  defuns = [];
  out = [ :defuns, defuns ];
  
  while (inp.empty?.!)
    defuns << parse_defun(inp);
  end
  
  return out;
end

$globals = {}; # name => :constructor | :native_constructor | :primordial | :builtin | :defun
$constructors = {}; # name => arity
$native_constructors = {}; # name => arity
$primordials = {}; # name => impl
$builtins = {}; # name => arity
$defuns = {}; # name => true

def wombat_register_constructor(name, arity)
  raise if (!(is_identifier(name)));
  raise if (!((0 <= arity) && (arity < 255))); # keep oal under 256
  
  raise if ($globals[name].nil?.!);
  
  $globals[name] = :constructor;
  $constructors[name] = arity;
end

def wombat_register_native_constructor(name, arity)
  raise if (!(is_identifier(name)));
  raise if (!((0 <= arity) && (arity < 255))); # keep oal under 256
  
  raise if ($globals[name].nil?.!);
  
  $globals[name] = :native_constructor;
  $native_constructors[name] = arity;
end

def wombat_register_primordial(name, impl)
  raise if (!(is_identifier(name)));
  
  raise if ($globals[name].nil?.!);
  
  $globals[name] = :primordial;
  $primordials[name] = impl;
end

def wombat_register_builtin(name, arity)
  raise if (!(is_identifier(name)));
  
  raise if ($globals[name].nil?.!);
  
  $globals[name] = :builtin;
  $builtins[name] = arity;
end

def wombat_register_defun(name, arity)
  raise if ($globals[name].nil?.!);
  
  $globals[name] = :defun;
  $defuns[name] = arity;
end

def convert_progn(node)
  case node[0]
  when :defuns
    return [ :defuns, node[1].map{|i| convert_progn(i); } ];
  when :defun
    return [ :defun, node[1], node[2], node[3], convert_progn(node[4]) ];
  when :identifier
    return node;
  when :blobcall
    return node;
  when :selfcall
    return node;
  when :let
    bindings = node[2].map{|bound, expr| [ bound, convert_progn(expr) ]; };
    body = convert_progn(node[3]);
    return [ :let, node[1], bindings, body ];
  when :lambda
    return [ :lambda, node[1], node[2], convert_progn(node[3]) ];
  when :case
    return [ :case, node[1], convert_progn(node[2]), node[3].map{|constructor, bindings, expr2| [ constructor, bindings, convert_progn(expr2) ]; } ];
  when :progn
    exprs = node[2];
    raise if (exprs.length == 0);
    return exprs[0] if (exprs.length == 1);
    return [ :let, node[1], exprs[0..-2].map{|i| [ "_", convert_progn(i) ]; }, convert_progn(exprs[-1]) ];
  when :funcall
    return [ :funcall, node[1], node[2].map{|expr| convert_progn(expr); } ];
  else
    raise;
  end
end

def convert_single_let(node)
  case node[0]
  when :defuns
    return [ :defuns, node[1].map{|i| convert_single_let(i); } ];
  when :defun
    return [ :defun, node[1], node[2], node[3], convert_single_let(node[4]) ];
  when :identifier
    return node;
  when :blobcall
    return node;
  when :selfcall
    return node;
  when :let
    bindings = node[2];
    body = node[3];
    remainder = nil;
    if (bindings.length > 1)
      remainder = [ :let, node[1], bindings[1..-1], body ];
    else
      remainder = body;
    end
    return [ :let, node[1], bindings[0][0], convert_single_let(bindings[0][1]), convert_single_let(remainder) ];
  when :lambda
    return [ :lambda, node[1], node[2], convert_single_let(node[3]) ];
  when :case
    return [ :case, node[1], convert_single_let(node[2]), node[3].map{|constructor, bindings, expr2| [ constructor, bindings, convert_single_let(expr2) ]; } ];
  when :funcall
    return [ :funcall, node[1], node[2].map{|expr| convert_single_let(expr); } ];
  else
    raise;
  end
end

def register_defuns(node)
  raise if (!(node[0] == :defuns));
  
  node[1].each{|subnode|
    wombat_register_defun(subnode[2], subnode[3].length);
  };
end

require("set");

$available = {};
$free_variables = {};

def calculate_free_variables(node, available)
  p node;
  p available;
  
  $available[node.object_id] = available;
  
  case node[0]
  when :defuns
    node[1].each{|i| calculate_free_variables(i, available); };
  when :defun
    calculate_free_variables(node[4], available.union(Set.new(node[3])));
    $free_variables[node.object_id] = ($free_variables[node[4].object_id] - Set.new(node[3]));
  when :identifier
    if (available.include?(node[1]))
      $free_variables[node.object_id] = Set.new([ node[1] ]);
    elsif ($globals[node[1]])
      $free_variables[node.object_id] = Set.new;
    else
      raise("not available and not global '#{node[1]}'");
    end
  when :blobcall
    $free_variables[node.object_id] = Set.new;
  when :selfcall
    $free_variables[node.object_id] = Set.new;
  when :let
    identifier = node[2];
    assignment = node[3];
    expression = node[4];
    calculate_free_variables(assignment, available);
    calculate_free_variables(expression, available.union(Set.new([ identifier ])));
    $free_variables[node.object_id] = ($free_variables[assignment.object_id] + ($free_variables[expression.object_id] - Set.new([ identifier ])));
  when :lambda
    bindings = node[2];
    expression = node[3];
    calculate_free_variables(expression, available.union(Set.new(bindings)));
    $free_variables[node.object_id] = ($free_variables[expression.object_id] - Set.new(bindings));
  when :case
    expr = node[2];
    calculate_free_variables(expr, available);
    union = Set.new;
    union += $free_variables[expr.object_id];
    node[3].each{|constructor, bindings, expr2|
      calculate_free_variables(expr2, available.union(Set.new(bindings)));
      union += ($free_variables[expr2.object_id] - Set.new(bindings));
    };
    $free_variables[node.object_id] = union;
  when :funcall
    accumulator = Set.new;
    node[2].each{|expr|
      calculate_free_variables(expr, available);
      accumulator += $free_variables[expr.object_id];
    };
    $free_variables[node.object_id] = accumulator;
  else
    raise;
  end
end

def c_ify(name)
  return "_" if (name == "_");
  
  return name.chars.map{|x|
    if (x == "-")
      "_minus_";
    elsif (x == "_")
      "_underscore_";
    else
      x;
    end
  }.join;
end

$ocaml_enabled = false;

$ocaml_impl = [];

$ocaml_ctr = 0;

def wombat_enable_ocaml()
  $ocaml_enabled = true;
end

def wombat_ocaml(code)
  $ocaml_impl << code;
end

1.times{
  $ocaml_impl << <<EOF
type wombat_blob =
| Wombat_Blob
;;

let wombat_construct_blob (x : 'a) : wombat_blob = failwith "oops";;
EOF
  
  $ocaml_impl << <<EOF
type wombatx_blob =
| Wombatx_Blob
;;

let wombatx_construct_blob (x : 'a) : wombatx_blob = failwith "oops";;
EOF
  
  (0...10).each{|i|
    s = (1..i).map{|j| "'a#{j}"; }.join(", ");
    s = "(#{s})" if (s.empty?.!);
    t = (1..i).map{|j| "'a#{j}"; }.join(" * ");
    t = "of #{t}" if (t.empty?.!);
    u = (1..i).map{|j| "a#{j}"; }.join(" ");
    v = (1..i).map{|j| "a#{j}"; }.join(", ");
    v = "(#{v})" if (v.empty?.!);
    $ocaml_impl << <<EOF
type #{s} wombatxvector#{i} =
| WombatxVector#{i} #{t}
;;

let consWombatxVector#{i} #{u} = (WombatxVector#{i} #{v});;
EOF
  };
};

def code_generate_ocaml(node, enclosing)
  parens_maybe = ->(x){
    return "" if (x.empty?);
    return "(#{x})";
  };
  
  case node[0]
  when :defuns
    node[1].each{|i| code_generate_ocaml(i, enclosing); };
    return nil;
  when :defun
    funname = node[2];
    formals = node[3];
    funbody = node[4];
    enclosing = "wombat_defun_#{c_ify(funname)}";
    formals2 = formals.map{|i| c_ify(i); };
    $ocaml_impl << "let rec #{enclosing} #{formals2.join(" ")} = #{code_generate_ocaml(funbody, enclosing)};;";
    return nil;
  when :identifier
    if ($available[node.object_id].include?(node[1]))
      return "#{c_ify(node[1])}";
    elsif ($globals[node[1]])
      case $globals[node[1]]
      when :constructor
        return "wombat_constructor_#{c_ify(node[1])}";
      when :native_constructor
        return "wombat_native_constructor_#{c_ify(node[1])}";
      when :primordial
        return "wombat_primordial_#{c_ify(node[1])}";
      when :builtin
        return "wombat_builtin_#{c_ify(node[1])}";
      when :defun
        return "wombat_defun_#{c_ify(node[1])}";
      else
        raise;
      end
    else
      raise;
    end
  when :let
    identifier = node[2];
    assignment = node[3];
    expression = node[4];
    return "(let #{c_ify(identifier)} = #{code_generate_ocaml(assignment, enclosing)} in #{code_generate_ocaml(expression, enclosing)})";
  when :lambda
    bindings = node[2];
    expression = node[3];
    tmp = ($ocaml_ctr += 1);
    enclosing = "wombat_lambda_#{tmp}";
    return "(let rec #{enclosing} #{bindings.join(" ")} = #{code_generate_ocaml(expression, enclosing)} in #{enclosing})";
  when :case
    expr = node[2];
    cases = node[3];
    out = [];
    out << "(match #{code_generate_ocaml(expr, enclosing)} with";
    cases.each{|constructor, bindings, expr2|
      bindings2 = bindings.map{|i| c_ify(i); };
      out << "| Wombat_#{constructor} #{parens_maybe.call(bindings2.join(", "))} -> #{code_generate_ocaml(expr2, enclosing)}";
    };
    out << ")";
    return out.join("\n");
  when :funcall
    exprs = node[2];
    raise if (!(exprs.length > 0));
    knownfun = nil;
    knownfun = "wombat_construct_blob" if (exprs[0][0] == :blobcall);
    knownfun = enclosing if (exprs[0][0] == :selfcall);
    if (exprs[0][0] == :identifier)
      ident = exprs[0][1];
      if ($available[exprs[0].object_id].include?(ident).!)
        case $globals[ident]
        when :constructor
          knownfun = "wombat_constructor_#{c_ify(ident)}";
        when :native_constructor
          knownfun = "wombat_native_constructor_#{c_ify(ident)}";
        when :builtin
          knownfun = "wombat_builtin_#{c_ify(ident)}";
        when :defun
          knownfun = "wombat_defun_#{c_ify(ident)}";
        else
          raise;
        end
      end
    end
    if (knownfun.nil?.!)
      exprs = exprs[1..-1];
      arguments = exprs.map{|i| code_generate_ocaml(i, enclosing); };
      return "(#{knownfun} #{arguments.join(" ")})";
    else
      arguments = exprs.map{|i| code_generate_ocaml(i, enclosing); };
      return "(#{arguments.join(" ")})";
    end
  else
    raise;
  end
end

def code_generate_ocamlx(node, enclosing)
  parens_maybe = ->(x){
    return "" if (x.empty?);
    return "(#{x})";
  };
  
  case node[0]
  when :defuns
    node[1].each{|i| code_generate_ocamlx(i, enclosing); };
    return nil;
  when :defun
    funname = node[2];
    formals = node[3];
    funbody = node[4];
    enclosing = "wombatx_defun_#{c_ify(funname)}";
    tmp2 = ($ocaml_ctr += 1);
    formals2 = formals.map{|i| c_ify(i); };
    u = parens_maybe.call("#{formals2.join(",")}");
    $ocaml_impl << "let rec #{enclosing} wombatx_args_#{tmp2} = (match wombatx_args_#{tmp2} with (WombatxVector#{formals.length} #{u}) -> #{code_generate_ocamlx(funbody, enclosing)});;";
    return nil;
  when :identifier
    if ($available[node.object_id].include?(node[1]))
      return "#{c_ify(node[1])}";
    elsif ($globals[node[1]])
      case $globals[node[1]]
      when :constructor
        return "wombatx_constructor_#{c_ify(node[1])}";
      when :native_constructor
        return "wombatx_native_constructor_#{c_ify(node[1])}";
      when :primordial
        return "wombatx_primordial_#{c_ify(node[1])}";
      when :builtin
        return "wombatx_builtin_#{c_ify(node[1])}";
      when :defun
        return "wombatx_defun_#{c_ify(node[1])}";
      else
        raise;
      end
    else
      raise;
    end
  when :let
    identifier = node[2];
    assignment = node[3];
    expression = node[4];
    return "(let #{c_ify(identifier)} = #{code_generate_ocamlx(assignment, enclosing)} in #{code_generate_ocamlx(expression, enclosing)})";
  when :lambda
    bindings = node[2];
    expression = node[3];
    tmp = ($ocaml_ctr += 1);
    enclosing = "wombatx_lambda_#{tmp}";
    tmp2 = ($ocaml_ctr += 1);
    u = parens_maybe.call("#{bindings.join(",")}");
    return "(let rec #{enclosing} wombatx_args_#{tmp2} = (match wombatx_args_#{tmp2} with (WombatxVector#{bindings.length} #{u}) -> #{code_generate_ocamlx(expression, enclosing)}) in #{enclosing})";
  when :case
    expr = node[2];
    cases = node[3];
    out = [];
    out << "(match #{code_generate_ocamlx(expr, enclosing)} with";
    cases.each{|constructor, bindings, expr2|
      bindings2 = bindings.map{|i| c_ify(i); };
      out << "| Wombatx_#{constructor} #{parens_maybe.call(bindings2.join(", "))} -> #{code_generate_ocamlx(expr2, enclosing)}";
    };
    out << ")";
    return out.join("\n");
  when :funcall
    exprs = node[2];
    raise if (!(exprs.length > 0));
    knownfun = nil;
    knownfun = "wombatx_construct_blob" if (exprs[0][0] == :blobcall);
    knownfun = enclosing if (exprs[0][0] == :selfcall);
    if (exprs[0][0] == :identifier)
      ident = exprs[0][1];
      if ($available[exprs[0].object_id].include?(ident).!)
        case $globals[ident]
        when :constructor
          knownfun = "wombatx_constructor_#{c_ify(ident)}";
        when :native_constructor
          knownfun = "wombatx_native_constructor_#{c_ify(ident)}";
        when :builtin
          knownfun = "wombatx_builtin_#{c_ify(ident)}";
        when :defun
          knownfun = "wombatx_defun_#{c_ify(ident)}";
        else
          raise;
        end
      end
    end
    if (knownfun.nil?.!)
      exprs = exprs[1..-1];
      arguments = exprs.map{|i| code_generate_ocamlx(i, enclosing); };
      return "(#{knownfun} (consWombatxVector#{arguments.length} #{arguments.join(" ")}))";
    else
      arguments = exprs.map{|i| code_generate_ocamlx(i, enclosing); };
      fun = arguments[0];
      args = arguments[1..-1];
      return "(#{fun} (consWombatxVector#{args.length} #{args.join(" ")}))";
    end
  else
    raise;
  end
end

$ctr = 0;

$c_constructors = [];
$c_lambda_constructors = [];

$c_lambda_decl = [];
$c_lambda_impl = [];

$c_defun_decl = [];
$c_defun_impl = [];

def code_generate(node, enclosing)
  case node[0]
  when :defuns
    node[1].each{|i| code_generate(i, enclosing); };
    return nil;
  when :defun
    funname = node[2];
    formals = node[3];
    funbody = node[4];
    params = [ "WombatExternal* wombat_external WOMBAT_UNUSED", "uintptr_t* wombat_context WOMBAT_UNUSED", ];
    formals.each_with_index{|formal, index|
      params << "uintptr_t* wombat_parameter_#{index} WOMBAT_UNUSED";
    };
    enclosing = "wombat_defun_#{c_ify(funname)}";
    $c_defun_decl << "static inline uintptr_t* wombat_defun_#{c_ify(funname)}(#{params.join(", ")});";
    $c_defun_impl << "static inline uintptr_t* wombat_defun_#{c_ify(funname)}(#{params.join(", ")}) {";
    formals.each_with_index{|formal, index|
      $c_defun_impl << "  {";
      $c_defun_impl << "    uintptr_t* #{c_ify(formal)} WOMBAT_UNUSED = wombat_parameter_#{index};";
    };
    $c_defun_impl << "    return #{code_generate(funbody, enclosing)};";
    formals.each{
      $c_defun_impl << "  }";
    };
    $c_defun_impl << "}";
    return nil;
  when :identifier
    if ($available[node.object_id].include?(node[1]))
      return "#{c_ify(node[1])}";
    elsif ($globals[node[1]])
      case $globals[node[1]]
      when :constructor
        return "wombat_lambda_constructor_#{c_ify(node[1])}";
      when :native_constructor
        return "wombat_lambda_native_constructor_#{c_ify(node[1])}";
      when :primordial
        # swallow const here; it's just too much work to make everything const-correct
        return "((uintptr_t*)(wombat_primordial_#{c_ify(node[1])}))";
      when :builtin
        return "wombat_lambda_builtin_#{c_ify(node[1])}";
      when :defun
        return "wombat_lambda_defun_#{c_ify(node[1])}";
      else
        raise;
      end
    else
      raise;
    end
  when :let
    identifier = node[2];
    assignment = node[3];
    expression = node[4];
    tmp = ($ctr += 1);
    return "({ /* +let */ uintptr_t* wombat_tmp#{tmp} = (#{code_generate(assignment, enclosing)}); uintptr_t* #{c_ify(identifier)} WOMBAT_UNUSED = wombat_tmp#{tmp}; #{code_generate(expression, enclosing)}; /* -let */ })";
  when :lambda
    bindings = node[2];
    expression = node[3];
    context = $free_variables[node.object_id].to_a.sort;
    params = [ "WombatExternal* wombat_external WOMBAT_UNUSED",
               "uintptr_t* wombat_context WOMBAT_UNUSED", ] +
             bindings.map{|bind| "uintptr_t* wombat_parameter_#{c_ify(bind)}"; };
    tmp = ($ctr += 1);
    $c_lambda_decl << "static inline uintptr_t* wombat_lambda_#{tmp}(#{params.join(", ")});";
    $c_lambda_impl << "static inline uintptr_t* wombat_lambda_#{tmp}(#{params.join(", ")}) {";
    context.each_with_index{|variable, index|
      raise if (bindings.include?(variable));
      $c_lambda_impl << "  {";
      $c_lambda_impl << "    uintptr_t* #{c_ify(variable)} WOMBAT_UNUSED = ((uintptr_t*)(wombat_context[#{2+index}]));";
    };
    bindings.each{|variable|
      $c_lambda_impl << "  {";
      $c_lambda_impl << "    uintptr_t* #{c_ify(variable)} WOMBAT_UNUSED = wombat_parameter_#{c_ify(variable)};";
    };
    expression = code_generate(expression, "wombat_lambda_#{tmp}");
    $c_lambda_impl << "    return #{expression};";
    bindings.each{|variable|
      $c_lambda_impl << "  }";
    };
    context.each_with_index{|variable, index|
      $c_lambda_impl << "  }";
    };
    $c_lambda_impl << "}";
    $c_lambda_constructors << [ bindings.length, context.length ];
    contextuals = context.map{|i| "#{c_ify(i)}"; };
    args = [
      "wombat_external",
      "WOMBAT_CONSTRUCTOR_LAMBDA_#{bindings.length}_#{context.length}",
      "((uintptr_t*)(wombat_lambda_#{tmp}))",
    ] + contextuals;
    $c_constructors << (2 + context.length);
    return "(wombat_constructor_#{(2 + context.length)}(#{args.join(", ")}))";
  when :case
    expr = node[2];
    cases = node[3];
    out = [];
    out << "({ /* +case */";
    tmp = ($ctr += 1);
    out << "  uintptr_t* wombat_tmp#{tmp} = #{code_generate(expr, enclosing)};";
    out << "  uintptr_t wombat_tmp#{tmp}_0 = wombat_tmp#{tmp}[0];";
    out << "  uintptr_t* wombat_retv = NULL;";
    first = true;
    cases.each{|constructor, bindings, expr2|
      maybe_else = "";
      maybe_else = "  else" if (!first); first = false;
      out << "#{maybe_else}  if (wombat_tmp#{tmp}_0 == WOMBAT_CONSTRUCTOR_#{constructor}) {";
      bindings.each_with_index{|symbol, index|
        out << "    uintptr_t* #{c_ify(symbol)} WOMBAT_UNUSED = ((uintptr_t*)(wombat_tmp#{tmp}[1+#{index}]));";
      };
      out << "    wombat_retv = #{code_generate(expr2, enclosing)};";
      out << "  }";
    };
    out << "  else { wombat_panic(wombat_external, wombat_tmp#{tmp}); }";
    out << "  wombat_retv; /* -case */ })";
    return out.join("\n");
  when :funcall
    exprs = node[2];
    raise if (!(exprs.length > 0));
    knownfun = nil;
    knownfun = "wombat_native_constructor_blob" if (exprs[0][0] == :blobcall);
    knownfun = enclosing if (exprs[0][0] == :selfcall);
    if (exprs[0][0] == :identifier)
      ident = exprs[0][1];
      if ($available[exprs[0].object_id].include?(ident).!)
        case $globals[ident]
        when :constructor
          knownfun = "wombat_constructor_#{c_ify(ident)}";
        when :native_constructor
          knownfun = "wombat_native_constructor_#{c_ify(ident)}";
        when :builtin
          knownfun = "wombat_builtin_#{c_ify(ident)}";
        when :defun
          knownfun = "wombat_defun_#{c_ify(ident)}";
        else
          raise;
        end
      end
    end
    if (knownfun.nil?.!)
      exprs = exprs[1..-1];
      out = [];
      out << "({ /* +funcall.knownfun */";
      tmp = ($ctr += 1);
      exprs.each_with_index{|expr, index|
        out << "  ({";
        out << "    uintptr_t* wombat_tmp#{tmp}_#{index} = #{code_generate(expr, enclosing)};";
      };
      arguments = exprs;
      arity = arguments.length;
      arguments = [ "wombat_external", "wombat_context" ] + arguments.map.with_index{|expr, index| "wombat_tmp#{tmp}_#{index}"; };
      out << "  (#{knownfun}(#{arguments.join(", ")}));";
      exprs.each{
        out << "  });";
      };
      out << "/* -funcall.knownfun */ })";
      return out.join("\n");
    else
      out = [];
      out << "({ /* +funcall.generic */";
      tmp = ($ctr += 1);
      exprs.each_with_index{|expr, index|
        out << "  ({";
        out << "    uintptr_t* wombat_tmp#{tmp}_#{index} = #{code_generate(expr, enclosing)};";
      };
      raise if (!(exprs.length > 0));
      arity = (exprs.length - 1);
      # ugh. this can actually result in allocating entries even if
      # the program doesn't use them. oh well. shouldn't have a
      # performance impact.
      $c_lambda_constructors << [ arity, 0 ];
      out << "#ifndef WOMBAT_UNSAFE_OPTIMIZATIONS";
      out << "  if (!((WOMBAT_CONSTRUCTOR_LAMBDA_#{arity}_LO <= wombat_tmp#{tmp}_0[0]) && (wombat_tmp#{tmp}_0[0] <= WOMBAT_CONSTRUCTOR_LAMBDA_#{arity}_HI))) {";
      out << "    wombat_panic(wombat_external, wombat_tmp#{tmp}_0);";
      out << "  }";
      out << "#endif";
      params = [ "WombatExternal*", "uintptr_t*", ] + (0...arity).map{|i| "uintptr_t*"; };
      args = [ "wombat_external", "wombat_tmp#{tmp}_0", ] + (0...arity).map{|i| "wombat_tmp#{tmp}_#{i+1}"; };
      out << "  (((uintptr_t* (*)(#{params.join(", ")}))(wombat_tmp#{tmp}_0[1]))(#{args.join(", ")}));";
      exprs.each{
        out << "  });";
      };
      out << " /* -funcall.generic */ })";
      return out.join("\n");
    end
  else
    raise;
  end
end

def main()
  toplevel = tokenize(ARGV[0], IO.read(ARGV[0]));
  p toplevel;
  
  while (true)
    toplevel_next = eliminate_require_lisp(toplevel);
    break if (toplevel_next == toplevel);
    toplevel = toplevel_next;
    p toplevel;
  end
  
  toplevel = handle_require_ruby(toplevel);
  p toplevel;
  
  1.times{
    ids = toplevel.map{|token| token[1].object_id; };
    raise if (ids.uniq.length != ids.length);
  };
  
  toplevel = parse_expressions(toplevel);
  p "after parse_expressions";
  p toplevel;
  
  # TODO: validation passes
  
  toplevel = convert_progn(toplevel);
  p "after convert_progn";
  p toplevel;
  
  toplevel = convert_single_let(toplevel);
  p "after convert_single_let";
  p toplevel;
  
  register_defuns(toplevel);
  
  calculate_free_variables(toplevel, Set.new);
  p "after calculate_free_variables";
  p $free_variables;
  
  if ($ocaml_enabled)
    code_generate_ocaml(toplevel, nil);
    code_generate_ocamlx(toplevel, nil);
    IO.write("wombat.ml", $ocaml_impl.join("\n"));
  end
  
  code_generate(toplevel, nil);
  
  c_define_constructor_impl = [];
  c_constructor_sizes = [];
  
  1.times {
    cons = -1;
    
    tmp = (cons += 1);
    c_define_constructor_impl << "#define WOMBAT_CONSTRUCTOR_INVALID #{tmp}";
    c_constructor_sizes << 0;
    
    prev_bl = nil;
    
    $c_lambda_constructors.to_a.sort.uniq.each{|blcl|
      p blcl;
      
      bl, cl, = blcl;
      
      if (bl != prev_bl)
        c_define_constructor_impl << "#define WOMBAT_CONSTRUCTOR_LAMBDA_#{prev_bl}_HI #{tmp}" if (prev_bl.nil?.!);
        tmp = (cons += 1);
        c_define_constructor_impl << "#define WOMBAT_CONSTRUCTOR_LAMBDA_#{bl}_LO #{tmp}";
      else
        tmp = (cons += 1);
      end
      
      c_define_constructor_impl << "#define WOMBAT_CONSTRUCTOR_LAMBDA_#{bl}_#{cl} #{tmp}";
      c_constructor_sizes << (1+1+cl);
      
      prev_bl = bl;
    };
    
    if (prev_bl != nil)
      c_define_constructor_impl << "#define WOMBAT_CONSTRUCTOR_LAMBDA_#{prev_bl}_HI #{tmp}";
    end
    
    $constructors.each{|name, arity|
      tmp = (cons += 1);
      c_define_constructor_impl << "#define WOMBAT_CONSTRUCTOR_#{name} #{tmp}";
      c_constructor_sizes << (1+arity);
    };
    
    c_define_constructor_impl << "#define WOMBAT_LAST_NON_NATIVE_CONSTRUCTOR #{cons}";
    
    $native_constructors.each{|name, arity|
      tmp = (cons += 1);
      c_define_constructor_impl << "#define WOMBAT_NATIVE_CONSTRUCTOR_#{name} #{tmp}";
      c_constructor_sizes << (1+arity);
    };
    
    c_define_constructor_impl << "static const uint8_t wombat_constructor_sizes[] = { #{c_constructor_sizes.join(", ")} };";
  };
  
  c_constructor_decl = [];
  c_constructor_impl = [];
  
  1.times {
    $constructors.each{|name, arity|
      params = [
        "WombatExternal* wombat_external WOMBAT_UNUSED",
        "uintptr_t* wombat_context WOMBAT_UNUSED",
      ] + (0...arity).map{|i| "uintptr_t* wombat_parameter_#{i}"; };
      c_constructor_decl << "static inline uintptr_t* wombat_constructor_#{c_ify(name)}(#{params.join(", ")});";
      c_constructor_impl << "static inline uintptr_t* wombat_constructor_#{c_ify(name)}(#{params.join(", ")}) {";
      args = [ "wombat_external", "WOMBAT_CONSTRUCTOR_#{c_ify(name)}", ] + (0...arity).map{|i| "wombat_parameter_#{i}"; };
      $c_constructors << (1 + arity);
      c_constructor_impl << "  return wombat_constructor_#{(1 + arity)}(#{args.join(", ")});";
      c_constructor_impl << "}";
    };
    
    $native_constructors.each{|name, arity|
      params = [
        "WombatExternal* wombat_external",
        "uintptr_t* wombat_context WOMBAT_UNUSED",
      ];
      c_constructor_decl << "static inline uintptr_t* wombat_native_constructor_#{c_ify(name)}(#{params.join(", ")});";
      c_constructor_impl << "static inline uintptr_t* wombat_native_constructor_#{c_ify(name)}(#{params.join(", ")}) {";
      args = [ "wombat_external", "WOMBAT_NATIVE_CONSTRUCTOR_#{c_ify(name)}", ] + (0...arity).map{|i| "0"; };
      $c_constructors << (1 + arity);
      c_constructor_impl << "  return wombat_constructor_#{(1 + arity)}(#{args.join(", ")});";
      c_constructor_impl << "}";
    };

    c_constructor_decl << "static inline uintptr_t* wombat_native_constructor_blob(WombatExternal*, uintptr_t*, uintptr_t*);";
    c_constructor_impl << "static inline uintptr_t* wombat_native_constructor_blob(WombatExternal* wombat_external, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* wombat_object) {";
    c_constructor_impl << "  uintptr_t len0 = wombat_measure(wombat_external, wombat_object);";
    c_constructor_impl << "  uintptr_t len = (1 + ((len0 + sizeof(uintptr_t) - 1) / sizeof(uintptr_t)));";
    c_constructor_impl << "  uintptr_t* retv = wombat_malloc(wombat_external, len);";
    c_constructor_impl << "  retv[0] = ((1UL << ((8*sizeof(uintptr_t))-1)) | len0);";
    c_constructor_impl << "  /* need to clear remainder of object here for determinism */";
    c_constructor_impl << "  for (uintptr_t i = 1; i < len; i++) { retv[i] = 0; }";
    c_constructor_impl << "  return retv;";
    c_constructor_impl << "}";
  };
  
  c_basic_constructor_impl = [];
  
  1.times{
    $c_constructors.sort.uniq.each{|arity|
      params = [
        "WombatExternal* wombat_external WOMBAT_UNUSED",
        "uintptr_t wombat_parameter_0",
      ] + (1...arity).map{|i| "uintptr_t* wombat_parameter_#{i}"; };
      c_basic_constructor_impl << "static inline uintptr_t* wombat_constructor_#{arity}(#{params.join(", ")}) {";
      c_basic_constructor_impl << "  uintptr_t* retv = wombat_malloc(wombat_external, #{arity});";
      (0...arity).each{|i|
        c_basic_constructor_impl << "  retv[#{i}] = ((uintptr_t)(wombat_parameter_#{i}));";
      };
      c_basic_constructor_impl << "  return retv;";
      c_basic_constructor_impl << "}";
    };
  };
  
  finale = [];
  
  finale << "#include <stddef.h>";
  finale << "#include <stdint.h>";
  finale << "#define WOMBAT_UNUSED __attribute__((unused))";
  finale << "#define WOMBAT_BUILTIN __attribute__((unused,noinline))";
  finale << "typedef struct {";
  finale << "} WombatExternal;";
  finale << "static inline uintptr_t* wombat_malloc(WombatExternal* wombat_external, uintptr_t wombat_len);";
  finale << "__attribute__((noinline)) static uintptr_t wombat_measure(WombatExternal* wombat_external, uintptr_t* wombat_object);";
  finale << "__attribute__((noinline,noreturn)) static void wombat_panic(WombatExternal* wombat_external, uintptr_t* bad);";
  
  finale += c_define_constructor_impl;
  finale += c_basic_constructor_impl;
  finale += c_constructor_decl;
  finale += c_constructor_impl;
  1.times{
    $builtins.each{|name, arity|
      params = [
        "WombatExternal* wombat_external WOMBAT_UNUSED",
        "uintptr_t* wombat_context WOMBAT_UNUSED",
      ] + (0...arity).map{|i| "uintptr_t* wombat_parameter_#{i}"; };
      finale << "__attribute__((noinline)) static uintptr_t* wombat_builtin_#{c_ify(name)}(#{params.join(", ")});";
    };
    
    $primordials.each{|name, impl|
      finale << impl;
    };
  };
  finale += $c_lambda_decl;
  finale += $c_defun_decl;
  finale += $c_lambda_impl;
  finale += $c_defun_impl;
  
  IO.write("wombat.c", finale.join("\n"));
end

main;
