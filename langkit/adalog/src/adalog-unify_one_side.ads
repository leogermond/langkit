------------------------------------------------------------------------------
--                               A D A L O G                                --
--                                                                          --
--                     Copyright (C) 2016, AdaCore                          --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
------------------------------------------------------------------------------

with Adalog.Abstract_Relation; use Adalog.Abstract_Relation;
with Adalog.Logic_Var;
with Adalog.Relations;

--  Internal implementation package, not to be used directly by users a-priori.
--  TODO??? document the inner workings a bit more.

generic
   type L_Type is private;
   type R_Type is private;
   with function Equals (L : L_Type; R : R_Type) return Boolean is <>;
   with function Convert (From : R_Type) return L_Type is <>;
   with package Var is new Logic_Var (Element_Type => L_Type, others => <>);
   with function R_Image (Self : R_Type) return String is <>;
package Adalog.Unify_One_Side is

   type R_Type_Array is array (Positive range <>) of R_Type;

   -----------
   -- Unify --
   -----------

   type Unify is record
      Left    : Var.Var;
      Right   : R_Type;
      Changed : Boolean := False;
   end record;

   function Create
     (Left : Var.Var; Right : R_Type) return Unify
   is
     ((Left => Left, Right => Right, Changed => False));

   function Apply (Self : in out Unify) return Boolean;
   procedure Revert (Self : in out Unify);
   procedure Free (Self : in out Unify) is null;

   function Custom_Image (Self : Unify) return String
   is ("<Unify " & Var.Image (Self.Left) & " " & R_Image (Self.Right) & ">");

   package Rel is new Relations.Stateful_Relation (Unify);

   ------------
   -- Member --
   ------------

   --  TODO??? Why is member not implemented in terms of
   --  Relation.Stateful_Relation?

   type R_Type_Array_Access is access all R_Type_Array;

   type Member_T is new I_Relation with record
      Left           : Var.Var;
      Values         : R_Type_Array_Access;
      Current_Index  : Positive := 1;
      Changed        : Boolean := False;
      Domain_Checked : Boolean := False;
   end record;

   overriding function Solve_Impl (Self : in out Member_T) return Boolean;
   overriding procedure Reset (Self : in out Member_T);
   overriding procedure Cleanup (Self : in out Member_T);

   function Member
     (R : Var.Var; Vals : R_Type_Array) return Relation;

end Adalog.Unify_One_Side;
