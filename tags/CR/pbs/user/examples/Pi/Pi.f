      program compute_pi
      parameter (n = 2000000000)
      integer i
!      double precision w,x,sum,pi,f,a
      real*8 w,x,sum,pi,f,a

      f(a) = 4.d0/(1.d0+a*a)
      w = 1.0d0/n
      sum = 0.0d0
!$OMP PARALLEL DO PRIVATE(x), SHARED(w)
!$OMP& REDUCTION(+:sum)

      do i=1,n
        x = w*(i-0.5d0)
        sum = sum + f(x)
      enddo

      pi = w*sum
      print *,'pi = ',pi
      stop
      end

